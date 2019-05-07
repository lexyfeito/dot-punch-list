import 'dart:io';

import 'package:dot_punch_list/DBProvider.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'entry.dart';
import 'project.dart';

class CreateEditItem extends StatefulWidget {

  final List<Entry> entries;
  final Project project;
  final Entry entry;

  CreateEditItem({Key key, this.project, this.entries, this.entry}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CreateEditItemState(project: project, entries: entries, entry: entry);
}

class _CreateEditItemState extends State<CreateEditItem> {

  bool isEditing = false;
  Project project;
  List<Entry> entries;
  Entry entry;
  Entry newEntry;
  DatabaseHelper _dbHelper;
  var titleController = TextEditingController();
  var descriptionController = TextEditingController();
  var commentController = TextEditingController();
  var remarkController = TextEditingController();
  var locationController = TextEditingController();
  var issueController = TextEditingController();
  var coordinatesController = TextEditingController();
  var providerByController = TextEditingController();

  _CreateEditItemState({this.project, this.entries, this.entry}) {
    if (entry != null) {
      isEditing = true;
      newEntry = new Entry(
          Element: entry.Element,
          Location: entry.Location,
          Coordinates: entry.Coordinates,
          Title: entry.Title,
          Comments: entry.Comments,
          Issue: entry.Issue,
          Status: entry.Status,
          Time: entry.Time,
          Images: entry.Images.map((m) => m).toList(),
          DoneImages: entry.DoneImages.map((m) => m).toList(),
          Remarks: entry.Remarks,
          ProjectModel: project,
          ProvidedBy: entry.ProvidedBy
      );
    } else newEntry = new Entry();
  }

  @override
  void initState() {
    _dbHelper = DatabaseHelper.instance;
    locationController.text = newEntry.Location;
    titleController.text = newEntry.Title;
    commentController.text = newEntry.Comments;
    remarkController.text = newEntry.Remarks;
    issueController.text = newEntry.Issue;
    coordinatesController.text = newEntry.Coordinates;
    providerByController.text = newEntry.ProvidedBy;

    super.initState();
  }

  Future getImage(ImageSource source) async {
    var image = await ImagePicker.pickImage(source: source);

    return image;
  }

  _openCamera() {
    getImage(ImageSource.camera);
  }

  Future _openGallery() async {
    var image = await getImage(ImageSource.gallery);

    return image;
  }

  Future _copyFiles(List<File> images, List<File> from, List<File> contains) async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path;
    for (File image in from) {
      if (isEditing && contains.map((File e) => e.path).contains(image.path)) continue;
      var name = image.path.substring(image.path.lastIndexOf('/'));
      var newFile = await image.copy('$path$name');
      // images.add(newFile);
      images.length > 0 ? images[0] = newFile : images.add(newFile);
    }

    return images;
  }

  Future _save() async {
    if (!_formKey.currentState.validate() || newEntry.Element == null || newEntry.Images.isEmpty || newEntry.Status == null
    || (newEntry.Status == StatusEnum.done && newEntry.DoneImages.isEmpty)
    ) return;

    List<File> newImagesList = isEditing ? entry.Images : new List<File>();
    List<File> newDoneImagesList = isEditing ? entry.DoneImages : new List<File>();
    newImagesList = await _copyFiles(newImagesList, newEntry.Images, isEditing ? entry.Images : null);
    if (newEntry.Status == StatusEnum.done) {
      newDoneImagesList = await _copyFiles(newDoneImagesList, newEntry.DoneImages, isEditing ? entry.DoneImages : null);
    }

    if (!isEditing) {
      newEntry.Location = locationController.text;
      newEntry.Coordinates = coordinatesController.text;
      newEntry.Title = titleController.text;
      newEntry.Comments = commentController.text;
      newEntry.Issue = issueController.text;
      newEntry.Images = newImagesList;
      newEntry.DoneImages = newDoneImagesList;
      newEntry.Time = new DateTime.now();
      newEntry.Remarks = remarkController.text;
      newEntry.ProjectModel = project;
      newEntry.ProvidedBy = providerByController.text;
      newEntry.Id = await _dbHelper.insert(newEntry, "Entries");
      setState(() => entries.add(newEntry));
    } else {
      entry.Element = newEntry.Element;
      entry.Location = locationController.text;
      entry.Coordinates = coordinatesController.text;
      entry.Title = titleController.text;
      entry.Comments = commentController.text;
      entry.Issue = issueController.text;
      entry.Images = newImagesList;
      entry.DoneImages = newDoneImagesList;
      entry.Status = newEntry.Status;
      entry.Remarks = remarkController.text;
      entry.ProjectModel = project;
      entry.ProvidedBy = providerByController.text;
      await _dbHelper.update(entry, "Entries");
      setState(() => entry);
    }
    Navigator.pop(context);
  }

  final _formKey = GlobalKey<FormState>();

  String _fileName(File file) {
    return file.path.substring(file.path.lastIndexOf('/') + 1);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit entry' : 'Create new entry'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _save,
          )
        ],
      ),
//      floatingActionButton: FloatingActionButton(
//        child: Icon(Icons.camera),
//        onPressed: _openCamera,
//      ),
      body: Form(
        key: _formKey,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: DropdownButtonFormField(
                                  items: elements.map((element) {
                                    return DropdownMenuItem(
                                      value: element.Element,
                                      child: Text(element.Name),
                                    );
                                  }).toList(),
                                  hint: Text('Elements'),
                                  value: newEntry.Element,
                                  onChanged: (value) {
                                    setState(() {
                                      newEntry.Element = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Required field.';
                                    }
                                  },
                                ),
                              )
                            ],
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                                labelText: 'Location Description'
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Required field.';
                              }
                            },
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            controller: locationController,
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Coordinates',
                                  ),
                                  controller: coordinatesController,
                                ),
                              ),
                              IconButton(
                                color: Colors.green,
                                icon: Icon(Icons.location_on),
                                onPressed: () async {
                                  Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                                  setState(() => coordinatesController.text = "Lat: ${position.latitude}, Lng: ${position.longitude}");
                                },
                              )
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: 10.0),
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Issue',
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Required field.';
                                }
                              },
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              controller: issueController,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: 10.0),
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Provided By',
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Required field.';
                                }
                              },
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              controller: providerByController,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Text('Before Image', style: TextStyle(
                          fontSize: 18
                      )),
                      margin: EdgeInsets.only(bottom: 5, left: 5),
                    ),
//                SizedBox(
//                  height: 100.0,
//                  child: ListView(
//                      scrollDirection: Axis.horizontal,
//                      shrinkWrap: true,
//                      children: new List.from([
//                        Container(
//                          child: RaisedButton(
//                            padding: EdgeInsets.all(0),
//                            onPressed: _openGallery,
//                            child: Icon(Icons.photo_album),
//                          ),
//                          margin: EdgeInsets.only(left: 5),
//                        )
//                      ])..addAll(newEntry.Images.map((image) => Container(
//                        height: 100.0,
//                        margin: EdgeInsets.only(left: 5.0, right: 5.0),
//                        decoration: BoxDecoration(
//                            // borderRadius: BorderRadius.all(Radius.circular(5)),
//                            border: Border.all(
//                              style: BorderStyle.solid,
//                              color: Color.fromARGB(100, 100, 100, 100),
//                              width: 1,
//                            )
//                        ),
//                        child: Image.file(image, ),
//                      )).toList())
//                  ),
//                ),
                    Container(
                      margin: EdgeInsets.only(left: 10, right: 10),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: RaisedButton(
                              child: Text('Select Before Image'),
                              onPressed: () async {
                                var image = await _openGallery();
                                if (image != null) {
                                  setState(() {
                                    if (newEntry.Images.length > 0) newEntry.Images[0] = image;
                                    else newEntry.Images.add(image);
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10),
                      child: newEntry.Images.length > 0 ? Text('File Name: ${_fileName(newEntry.Images[0])}', style: TextStyle(fontSize: 12),) : null,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10.0, left: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text('Status', style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: <Widget>[
                          Radio(
                            value: StatusEnum.pending,
                            groupValue: newEntry.Status,
                            onChanged: (value) {
                              setState(() {
                                newEntry.Status = value;
                              });
                            },
                          ),
                          Text('Pending'),
                          Radio(
                            value: StatusEnum.done,
                            groupValue: newEntry.Status,
                            onChanged: (value) {
                              setState(() {
                                newEntry.Status = value;
                              });
                            },
                          ),
                          Text('Done'),
                        ],
                      ),
                    ),
                    Container(
                      child: Text('After Image', style: TextStyle(
                          fontSize: 18
                      )),
                      margin: EdgeInsets.only(bottom: 5, left: 5),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10, right: 10),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: RaisedButton(
                              child: Text('Select After Image'),
                              onPressed: newEntry.Status == StatusEnum.done ? () async {
                                var image = await _openGallery();
                                if (image != null) {
                                  setState(() {
                                    if (newEntry.DoneImages == null || newEntry.DoneImages.length == 0) {
                                      newEntry.DoneImages = new List();
                                      newEntry.DoneImages.add(image);
                                    } else newEntry.DoneImages[0] = image;
                                  });
                                }
                              } : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10),
                      child: newEntry.DoneImages != null && newEntry.DoneImages.length > 0 ? Text('File Name: ${_fileName(newEntry.DoneImages[0])}', style: TextStyle(fontSize: 12),) : null,
                    ),
                    Container(
                      padding: EdgeInsets.all(10.0),
                      child: TextFormField(
                        enabled: newEntry.Status == StatusEnum.done,
                        decoration: InputDecoration(
                          labelText: 'Remarks',
                        ),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        controller: remarkController,
                      ),
                    )
                  ],
                ),
              )
            ]),
      ),
    );
  }
}