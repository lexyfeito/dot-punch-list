import 'model.interface.dart';

class Project implements Model {
  int Id;
  String Name;
  String Description;
  bool Inactive;

  Project({this.Id, this.Name, this.Description, this.Inactive});

  factory Project.fromJson(Map<String, dynamic> json) => new Project(
    Id: json["id"],
    Name: json["name"],
    Description: json["description"],
    Inactive: json["inactive"] == 0 || json["inactive"] == null ? false : true,
  );

  Map<String, dynamic> toJson() => {
    "id": Id,
    "name": Name,
    "description": Description,
    "inactive": Inactive
  };
}