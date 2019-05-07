import 'dart:convert';
import 'dart:io';
import 'model.interface.dart';
import 'project.dart';

enum StatusEnum { pending, done }

enum ElementEnum { sod, drainage, water_mains, sewer, guardrail, concrete, mse_wall, retaining_wall, bridge, earthwork, asphalt, pavements_markings, signage, signal, lighting, its, fence, landscape, cleanup, mot, environmental, miscellaneous }

final elements = [
  new ElementModel(Name: 'Sod', Element: ElementEnum.sod),
  new ElementModel(Name: 'Drainage', Element: ElementEnum.drainage),
  new ElementModel(Name: 'Water Mains', Element: ElementEnum.water_mains),
  new ElementModel(Name: 'Sewer', Element: ElementEnum.sewer),
  new ElementModel(Name: 'Guardrail', Element: ElementEnum.guardrail),
  new ElementModel(Name: 'Concrete', Element: ElementEnum.concrete),
  new ElementModel(Name: 'MSE Wall', Element: ElementEnum.mse_wall),
  new ElementModel(Name: 'Retaining Wall', Element: ElementEnum.retaining_wall),
  new ElementModel(Name: 'Bridge', Element: ElementEnum.bridge),
  new ElementModel(Name: 'Earthwork', Element: ElementEnum.earthwork),
  new ElementModel(Name: 'Asphalt', Element: ElementEnum.asphalt),
  new ElementModel(Name: 'Pavement Markings', Element: ElementEnum.pavements_markings),
  new ElementModel(Name: 'Signage', Element: ElementEnum.signage),
  new ElementModel(Name: 'Signal', Element: ElementEnum.signal),
  new ElementModel(Name: 'Lighting', Element: ElementEnum.lighting),
  new ElementModel(Name: 'ITS', Element: ElementEnum.its),
  new ElementModel(Name: 'Fence', Element: ElementEnum.fence),
  new ElementModel(Name: 'Landscape', Element: ElementEnum.landscape),
  new ElementModel(Name: 'Cleanup', Element: ElementEnum.cleanup),
  new ElementModel(Name: 'MOT', Element: ElementEnum.mot),
  new ElementModel(Name: 'Environmental', Element: ElementEnum.environmental),
  new ElementModel(Name: 'Miscellaneous', Element: ElementEnum.miscellaneous)
];

final statuses = [
  new StatusModel(Id: StatusEnum.pending, Text: 'Pending'),
  new StatusModel(Id: StatusEnum.done, Text: 'Done')
];

class ElementModel {
  String Name;
  String Description;
  ElementEnum Element;
  bool Selected = false;

  ElementModel({this.Name, this.Description, this.Element});
}

class StatusModel {
  StatusEnum Id;
  String Text;

  StatusModel({this.Id, this.Text});
}

class Entry implements Model {
  int Id;
  ElementEnum Element;
  String Location;
  String Coordinates;
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
  String ProvidedBy;

  Entry({
    this.Id, this.Element,
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

  factory Entry.fromJson(Map<String, dynamic> json) => new Entry(
    Id: json["id"],
    Element: ElementEnum.values[json["element"]],
    Location: json["location"],
    Coordinates: json["coordinates"],
    Title: json["title"],
    Comments: json["comments"],
    Issue: json["issue"],
    Images: json["images"].toString().split(' ').toList().map((String i) => new File(i)).toList(),
    DoneImages: json["doneImages"].toString().isNotEmpty ? json["doneImages"].toString().split(' ').toList().map((String i) => new File(i)).toList() : new List(),
    Status: StatusEnum.values[json["status"]],
    Time: DateTime.parse(json["time"]),
    Remarks: json["remarks"],
    ProvidedBy: json["providedBy"]
  );

  Map<String, dynamic> toJson() => {
    "element": Element.index,
    "location": Location,
    "coordinates": Coordinates,
    "title": Title,
    "comments": Comments,
    "issue": Issue,
    "images": Images.map((File i) => i.path).toList().join(" "),
    "doneImages": DoneImages.map((File i) => i.path).toList().join(" "),
    "status": Status.index,
    "time": Time.toIso8601String(),
    "project": ProjectModel.Id,
    "remarks": Remarks,
    "providedBy": ProvidedBy,
  };

  Map<String, dynamic> toJson2() => {
    "element": element,
    "location": Location,
    "coordinates": Coordinates,
    "title": Title,
    "comments": Comments,
    "issue": Issue,
    "images": Images.map((File i) => base64.encode(i.readAsBytesSync())).toList(),
    "doneImages": DoneImages != null && DoneImages.length > 0 ? DoneImages.map((File i) => base64.encode(i.readAsBytesSync())).toList() : [],
    "status": status,
    "time": Time.toIso8601String(),
    "remarks": Remarks,
    "providedBy": ProvidedBy
  };

  String get element {
    if (Element != null) {
      return elements.firstWhere((element) => element.Element == Element).Name;
    }
    return "";
  }

  String get status {
    if (Status != null) {
      switch (Status.index) {
        case 0: return "Pending";
        case 1: return "Done";
      }
    }
    return "No Action";
  }
}