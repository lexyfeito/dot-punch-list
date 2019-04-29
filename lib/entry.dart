import 'dart:io';

enum StatusEnum { pending, done }

enum ElementEnum { afalto, concreto }

class StatusModel {
  StatusEnum Id;
  String Text;

  StatusModel({this.Id, this.Text});
}

class Entry {
  int Id;
  ElementEnum Element;
  String Location;
  String Title;
  String Description;
  String Comments;
  bool Fixed = false;
  List<File> Images;
  List<File> DoneImages;
  DateTime Time;
  StatusEnum Status;
  String Remarks;

  Entry({
    this.Id, this.Element,
    this.Location,
    this.Title,
    this.Description,
    this.Comments,
    this.Fixed = false,
    this.Images,
    this.DoneImages,
    this.Time,
    this.Status}) {
    if (this.Images == null) this.Images = new List();
    if (this.DoneImages == null) this.DoneImages = new List();
  }

  factory Entry.fromJson(Map<String, dynamic> json) => new Entry(
    Id: json["id"],
    Element: ElementEnum.values[json["element"]],
    Location: json["location"],
    Title: json["title"],
    Comments: json["comments"],
    Images: json["images"].toString().split(' ').toList().map((String i) => new File(i)).toList(),
    DoneImages: json["doneImages"].toString().split(' ').toList().map((String i) => new File(i)).toList(),
    Status: StatusEnum.values[json["status"]],
    Time: DateTime.parse(json["time"])
  );

  Map<String, dynamic> toJson() => {
    "element": Element.index,
    "location": "lat and lng",
    "title": Title,
    "comments": Comments,
    "images": Images.map((File i) => i.path).toList().join(" "),
    "doneImages": DoneImages.map((File i) => i.path).toList().join(" "),
    "status": Status.index,
    "time": Time.toIso8601String()
  };

  String get element {
    if (Element != null) {
      switch (Element.index) {
        case 0: return "Afalto";
        case 1: return "Concreto";
      }
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