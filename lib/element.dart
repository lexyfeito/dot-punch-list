import 'DBProvider.dart';
import 'model.interface.dart';
import 'dart:async';


enum ElementEnum { sod, drainage, water_mains, sewer, guardrail, concrete, mse_wall, retaining_wall, bridge, earthwork, asphalt, pavements_markings, signage, signal, lighting, its, fence, landscape, cleanup, mot, environmental, miscellaneous }

class ElementModel implements Model {
  int Id;
  String Name;
  String Description;
  bool Selected = false;
  bool Inactive = false;

  ElementModel({this.Id, this.Name, this.Description, this.Inactive}) {}

  factory ElementModel.fromJson(Map<String, dynamic> map) => new ElementModel(
      Id: map["id"],
      Name: map["name"],
      Description: map["description"],
      Inactive: map["inactive"] == 0 || map["inactive"] == null ? false : true
  );

  Map<String, dynamic> toJson() {
    return {
      "id": Id,
      "name": Name,
      "description": Description,
      "inactive": Inactive
    };
  }
}

abstract class ElementEvent {}

class GetElements extends ElementEvent {}
class AddElement extends ElementEvent {
  ElementModel element;
  AddElement(this.element);
}
class EditElement extends ElementEvent {
  ElementModel element;
  EditElement(this.element);
}
class RemoveElement extends ElementEvent {
  int id;
  RemoveElement(this.id);
}
class DeactivateElement extends ElementEvent {
  ElementModel element;
  DeactivateElement(this.element);
}

class ElementBloc {

  final _dbHelper = DatabaseHelper.instance;
  List<ElementModel> _elements = [];

  List<ElementModel> get elementsList => _elements;

  final _elementStateController = new StreamController<List<ElementModel>>.broadcast();
  StreamSink<List<ElementModel>> get _inElements => _elementStateController.sink;

  Stream<List<ElementModel>> get elements => _elementStateController.stream;

  final _elementEventController = StreamController<ElementEvent>.broadcast();

  Sink<ElementEvent> get elementEventSink => _elementEventController.sink;

  ElementBloc() {
    _elementEventController.stream.listen(_mapEventToState);
  }

  void _mapEventToState(ElementEvent event) async {
    if (event is GetElements) {
      var db = await _dbHelper.database;
      List<Map> maps = await db.query('Elements', where: "inactive = ?", whereArgs: [0], orderBy: "name");
      if (maps.length > 0) {
        _elements = maps.map((map) => ElementModel.fromJson(map)).toList();
      }
    } else if (event is AddElement) {
      event.element.Inactive = false;
      var id = await _dbHelper.insert(event.element, "Elements");
      event.element.Id = id;
      _elements.add(event.element);
    } else if (event is EditElement) {
      await _dbHelper.update(event.element, "Elements");
      final index = _elements.indexWhere((element) => element.Id == event.element.Id);
      _elements[index] = event.element;
    } else if (event is RemoveElement) {
      await _dbHelper.delete(event.id, "Elements");
      final index = _elements.indexWhere((element) => element.Id == event.id);
      _elements.removeAt(index);
    } else if (event is DeactivateElement) {
      event.element.Inactive = true;
      await _dbHelper.update(event.element, "Elements");
      final index = _elements.indexWhere((element) => element.Id == event.element.Id);
      _elements.removeAt(index);
    }

    _inElements.add(_elements);
  }

  void dispose() {
    _elementStateController.close();
    _elementEventController.close();
  }
}