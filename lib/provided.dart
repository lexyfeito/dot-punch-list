import 'dart:async';

import 'package:dot_punch_list/project.dart';

import 'DBProvider.dart';
import 'model.interface.dart';

class ProvidedModel implements Model {
  int Id;
  String Name;
  bool Selected;
  int ProjectId;
  bool Inactive;

  ProvidedModel({this.Id, this.Name, this.Selected = false, this.ProjectId, this.Inactive});

  Map<String, dynamic> toJson() => {
    "id": Id,
    "name": Name,
    'project_id': ProjectId,
    'inactive': Inactive
  };

  factory ProvidedModel.fromJson(Map<String, dynamic> map) => new ProvidedModel(
    Id: map["id"],
    Name: map["name"],
    ProjectId: map['project_id'],
    Inactive: map['inactive'] == 1
  );
}

abstract class ProvidedEvent {}

class GetProvidedEvent extends ProvidedEvent {
  Project project;
  GetProvidedEvent(this.project);
}
class AddProvidedEvent extends ProvidedEvent {
  ProvidedModel provided;
  AddProvidedEvent(this.provided);
}
class EditProvidedEvent extends ProvidedEvent {
  ProvidedModel provided;
  EditProvidedEvent(this.provided);
}
class DeactivateProvidedEvent extends ProvidedEvent {
  ProvidedModel provided;
  DeactivateProvidedEvent(this.provided);
}

class ProvidedBloc {
  final _dbHelper = DatabaseHelper.instance;
  List<ProvidedModel> _provided = [];
  List<ProvidedModel> get providedList => _provided;

  final _providedStateController = new StreamController<List<ProvidedModel>>.broadcast();
  StreamSink<List<ProvidedModel>> get _inProvided => _providedStateController.sink;

  Stream<List<ProvidedModel>> get provided => _providedStateController.stream;

  final _providedEventController = StreamController<ProvidedEvent>.broadcast();

  Sink<ProvidedEvent> get providedEventSink => _providedEventController.sink;

  ProvidedBloc() {
    _providedEventController.stream.listen(_mapEventToState);
  }

  _mapEventToState(ProvidedEvent event) async {
    if (event is GetProvidedEvent) {
      var db = await _dbHelper.database;
      List<Map> maps = await db.rawQuery("SELECT * FROM ProvidedBy WHERE project_id = '${event.project.Id}' AND (inactive is null OR inactive = 0) ORDER BY name ASC");
      if (maps.length > 0) {
        _provided = maps.map((map) => ProvidedModel.fromJson(map)).toList();
      }
    } else if (event is AddProvidedEvent) {
      var id = await _dbHelper.insert(event.provided, "ProvidedBy");
      event.provided.Id = id;
      _provided.add(event.provided);
    } else if (event is EditProvidedEvent) {
      await _dbHelper.update(event.provided, 'ProvidedBy');
      var index = _provided.indexWhere((i) => i.Id == event.provided.Id);
      _provided[index] = event.provided;
    } else if (event is DeactivateProvidedEvent) {
      await _dbHelper.update(event.provided, 'ProvidedBy');
      var index = _provided.indexWhere((i) => i.Id == event.provided.Id);
      _provided.removeAt(index);
    }

    _inProvided.add(_provided);
  }

  dispose() {
    this._providedStateController.close();
    this._providedEventController.close();
  }
}