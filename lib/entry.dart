import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dot_punch_list/provided.dart';
import 'package:sqflite/sqlite_api.dart';

import 'DBProvider.dart';
import 'element.dart';
import 'model.interface.dart';
import 'project.dart';
import 'element.dart' show ElementModel;

enum StatusEnum { pending, done, no_action }

final statuses = [
  new StatusModel(Id: StatusEnum.pending, Text: 'Pending'),
  new StatusModel(Id: StatusEnum.done, Text: 'Done'),
  new StatusModel(Id: StatusEnum.no_action, Text: 'No Action')
];

class StatusModel {
  StatusEnum Id;
  String Text;

  StatusModel({this.Id, this.Text});
}

class CoordinatesModel {
  double Latitude;
  double Longitude;

  CoordinatesModel(this.Latitude, this.Longitude);

  @override
  String toString() {
    return "Lat: ${this.Latitude}, Lng: ${this.Longitude}";
  }
}

class Entry implements Model {
  int Id;
  ElementModel Element;
  String Location;
  CoordinatesModel Coordinates;
  String Title;
  String Description;
  String Comments;
  String Issue;
  bool Fixed = false;
  List<File> Images;
  List<File> DoneImages;
  DateTime Time;
  StatusEnum Status;
  String Remarks;
  Project ProjectModel;
  ProvidedModel ProvidedBy;

  Entry({
    this.Id,
    this.Element,
    this.Location,
    this.Coordinates,
    this.Title,
    this.Description,
    this.Comments,
    this.Issue,
    this.Fixed = false,
    this.Images,
    this.DoneImages,
    this.Time,
    this.Status,
    this.Remarks,
    this.ProjectModel,
    this.ProvidedBy
  }) {
    if (this.Images == null) this.Images = new List();
    if (this.Status == null) this.Status = StatusEnum.pending;
  }

  factory Entry.fromJson(Map<String, dynamic> map) => new Entry(
    Id: map["id"],
    Element: new ElementModel(Id: map["elementId"], Name: map["elementName"], Description: map["elementDescription"]),
    Location: map["location"],
    Coordinates: map["coordinates"] != null ? new CoordinatesModel(double.parse(map["coordinates"].toString().split(' ').toList()[0]), double.parse(map["coordinates"].toString().split(' ').toList()[1])) : null,
    Title: map["title"],
    Comments: map["comments"],
    Issue: map["issue"],
    Images: map["images"] != null && map["images"].toString().isNotEmpty ? map["images"].toString().split(' ').toList().map((String i) => new File(i)).toList() : null,
    DoneImages: map["doneImages"].toString().isNotEmpty ? map["doneImages"].toString().split(' ').toList().map((String i) => new File(i)).toList() : new List(),
    Status: StatusEnum.values[map["status"]],
    Time: DateTime.parse(map["time"]),
    Remarks: map["remarks"],
    ProvidedBy: new ProvidedModel(Id: map["providedById"], Name: map["providedByName"])
  );

  Map<String, dynamic> toJson() => {
    "element": Element.Id,
    "location": Location,
    "coordinates": Coordinates != null ? "${Coordinates.Latitude} ${Coordinates.Longitude}" : null,
    "title": Title,
    "comments": Comments,
    "issue": Issue,
    "images": Images.map((File i) => i.path).toList().join(" "),
    "doneImages": DoneImages.map((File i) => i.path).toList().join(" "),
    "status": Status.index,
    "time": Time.toIso8601String(),
    "project": ProjectModel.Id,
    "remarks": Remarks,
    "providedBy": ProvidedBy.Id,
  };

  Map<String, dynamic> toJson2() => {
    "element": element,
    "location": Location,
    "coordinates": Coordinates != null ? "Lat: ${Coordinates.Latitude}, Lng: ${Coordinates.Longitude}" : null,
    "title": Title,
    "comments": Comments,
    "issue": Issue,
    "images": Images != null ? Images.map((File i) => base64.encode(i.readAsBytesSync())).toList() : null,
    "doneImages": DoneImages != null && DoneImages.length > 0 ? DoneImages.map((File i) => base64.encode(i.readAsBytesSync())).toList() : [],
    "status": status,
    "time": Time.toIso8601String(),
    "remarks": Remarks,
    "providedBy": providedBy
  };

  String get element {
    if (Element != null && Element.Name != null) {
      return Element.Name;
    }
    return "";
  }

  String get providedBy {
    if (ProvidedBy != null)
      return ProvidedBy.Name;

    return "";
  }

  String get status {
    if (Status != null) {
      switch (Status.index) {
        case 0: return "Pending";
        case 1: return "Done";
        case 2: return "No Action";
      }
    }
    return "No Action";
  }
}

abstract class EntryEvent {}

class GetEntries extends EntryEvent {
  Project project;
  String query;
  GetEntries(this.project, {this.query});
}
class AddEntry extends EntryEvent {
  Entry entry;
  AddEntry(this.entry);
}
class EditEntry extends EntryEvent {
  Entry entry;
  EditEntry(this.entry);
}
class RemoveEntry extends EntryEvent {
  int id;
  RemoveEntry(this.id);
}

class EntryBloc {
  final _dbHelper = DatabaseHelper.instance;

  List<Entry> _entries = [];

  final _entryStateController = new StreamController<List<Entry>>();
  StreamSink<List<Entry>> get _inEntries => _entryStateController.sink;

  Stream<List<Entry>> get entries => _entryStateController.stream;

  final _entryEventController = StreamController<EntryEvent>();

  Sink<EntryEvent> get entryEventSink => _entryEventController.sink;

  EntryBloc() {
    _entryEventController.stream.listen(_mapEventToState);
  }

  void _mapEventToState(EntryEvent event) async {
    if (event is GetEntries) {
      String query = "";
      if (event.query != null && event.query.isNotEmpty) {
        query += "(${event.query}) AND (Entries.project = ${event.project.Id})";
      } else query = "Entries.project = ${event.project.Id}";
      Database db = await _dbHelper.database;
      try {
        List<Map> maps = await db.rawQuery("SELECT Entries.*, Elements.id as elementId, Elements.name as elementName, Elements.description as elementDescription, ProvidedBy.id as providedById, ProvidedBy.name as providedByName FROM Entries LEFT JOIN Elements ON Entries.element = Elements.id LEFT JOIN ProvidedBy ON Entries.providedBy = ProvidedBy.id WHERE $query");
        _entries = maps.map((map) => Entry.fromJson(map)).toList();
      } catch (e) {
        print(e);
      }
    } else if (event is AddEntry) {
      var id = await _dbHelper.insert(event.entry, "Entries");
      event.entry.Id = id;
      _entries.add(event.entry);
    } else if (event is EditEntry) {
      await _dbHelper.update(event.entry, "Entries");
      final index = _entries.indexWhere((entry) => entry.Id == event.entry.Id);
      _entries[index] = event.entry;
    } else if (event is RemoveEntry) {
      await _dbHelper.delete(event.id, "Entries");
      final index = _entries.indexWhere((entry) => entry.Id == event.id);
      _entries.removeAt(index);
    }

    _inEntries.add(_entries);
  }

  void dispose() {
    _entryStateController.close();
    _entryEventController.close();
  }
}