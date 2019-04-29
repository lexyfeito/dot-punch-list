import 'dart:io';

import 'package:dot_punch_list/DBProvider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'entry.dart';
//import 'package:geolocator/geolocator.dart';

class CreateEditItem extends StatefulWidget {

  final List<Entry> entries;
  final Entry entry;

  CreateEditItem({Key key, this.entries, this.entry}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CreateEditItemState(entries: entries, entry: entry);
}

class _CreateEditItemState extends State<CreateEditItem> {

  bool isEditing = false;
  List<Entry> entries;
  Entry entry;
  Entry newEntry;
  DatabaseHelper _dbHelper;
  var titleController = TextEditingController();
  var descriptionController = TextEditingController();
  var commentController = TextEditingController();
  var locationController = TextEditingController();

  _CreateEditItemState({this.entries, this.entry}) {
    if (entry != null) {
      isEditing = true;
      newEntry = new Entry(
          Element: entry.Element,
          Location: entry.Location,
          Title: entry.Title,
          Comments: entry.Comments,
          Status: entry.Status,
          Time: entry.Time,
          Images: entry.Images.map((m) => m).toList());
    } else newEntry = new Entry();
  }

  @override
  void initState() {
    _dbHelper = DatabaseHelper.instance;
    locationController.text = newEntry.Location;
    titleController.text = newEntry.Title;
    commentController.text = newEntry.Comments;

    super.initState();
  }

  Future getImage(ImageSource source) async {
    var image = await ImagePicker.pickImage(source: source);

    if (image != null) {
      setState(() {
        newEntry.Images.add(image);
      });
    }
  }

  _openCamera() {
    getImage(ImageSource.camera);
  }

  _openGallery() {
    getImage(ImageSource.gallery);
  }

  Future _save() async {
    if (_formKey.currentState.validate() && newEntry.Element != null && newEntry.Images.isNotEmpty && newEntry.Status != null) {
//      var status = await Geolocator().checkGeolocationPermissionStatus();
//      Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      Directory directory = await getApplicationDocumentsDirectory();
      String path = directory.path;
      List<File> newImagesList = isEditing ? entry.Images : new List<File>();
      for (File image in newEntry.Images) {
        if (isEditing && entry.Images.map((File e) => e.path).contains(image.path)) continue;
        var name = image.path.substring(image.path.lastIndexOf('/'));
        var newFile = await image.copy('$path$name');
        newImagesList.add(newFile);
      }
      if (!isEditing) {
//        newEntry.Location = "${position.latitude}, ${position.longitude}";
        newEntry.Title = titleController.text;
        newEntry.Comments = commentController.text;
        newEntry.Images = newImagesList;
        newEntry.Time = new DateTime.now();
        newEntry.Id = await _dbHelper.insert(newEntry);
        setState(() => entries.add(newEntry));
      } else {
        setState(() {
          entry.Element = newEntry.Element;
          entry.Location = locationController.text;
          entry.Title = titleController.text;
          entry.Comments = commentController.text;
          entry.Images = newImagesList;
          entry.Status = newEntry.Status;
        });
        await _dbHelper.update(entry);
      }

      Navigator.pop(context);
    } else print('Invalid form');
  }

  final _formKey = GlobalKey<FormState>();
  final statuses = [
    new StatusModel(Id: StatusEnum.pending, Text: 'Pending'),
    new StatusModel(Id: StatusEnum.done, Text: 'Done')
  ];

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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera),
        onPressed: _openCamera,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: DropdownButtonFormField(
                              items: [
                                DropdownMenuItem(
                                  value: ElementEnum.afalto,
                                  child: Text('Afalto'),
                                ),
                                DropdownMenuItem(
                                  value: ElementEnum.concreto,
                                  child: Text('Concreto'),
                                )
                              ],
                              hint: Text('Elements'),
                              value: newEntry.Element,
                              onChanged: (value) {
                                setState(() {
                                  newEntry.Element = value;
                                });
                              },
                            ),
                          )
                        ],
                      ),
//                      TextFormField(
//                        decoration: InputDecoration(
//                          labelText: 'Location',
//                          hintText: 'Location',
//                        ),
//                        validator: (value) {
//                          if (value.isEmpty) {
//                            return 'Please enter some location';
//                          }
//                        },
//                        controller: locationController,
//                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Title',
                          hintText: 'Title',
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter some title';
                          }
                        },
                        controller: titleController,
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 10.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Comment',
                            labelText: 'Comment',
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some comment';
                            }
                          },
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          controller: commentController,
                        ),
                      ),
//                      Row(
//                        children: <Widget>[
//                          Expanded(
//                            child: DropdownButton<StatusEnum>(
//                              hint: Text('Status'),
//                              value: newEntry.Status,
//                              onChanged: (StatusEnum newValue) {
//                                setState(() {
//                                  newEntry.Status = newValue;
//                                });
//                              },
//                              items: statuses
//                                  .map((StatusModel status) {
//                                    return DropdownMenuItem<StatusEnum>(
//                                      value: status.Id,
//                                      child: Text(status.Text),
//                                    );
//                              }).toList(),
//                            ),
//                          )
//                        ],
//                      ),
                    ],
                  ),
                ),
                Container(
                  child: Text('Pictures', style: TextStyle(
                   fontSize: 18
                  )),
                  margin: EdgeInsets.only(bottom: 10.0, left: 5),
                ),
                SizedBox(
                  height: 100.0,
                  child: ListView(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      children: new List.from([
                        Container(
                          child: RaisedButton(
                            padding: EdgeInsets.all(0),
                            onPressed: _openGallery,
                            child: Icon(Icons.photo_album),
                          ),
                          margin: EdgeInsets.only(left: 5),
                        )
                      ])..addAll(newEntry.Images.map((image) => Container(
                        height: 100.0,
                        margin: EdgeInsets.only(left: 5.0, right: 5.0),
                        decoration: BoxDecoration(
                            // borderRadius: BorderRadius.all(Radius.circular(5)),
                            border: Border.all(
                              style: BorderStyle.solid, 
                              color: Color.fromARGB(100, 100, 100, 100), 
                              width: 1,
                            )
                        ),
                        child: Image.file(image, ),
                      )).toList())
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10.0, left: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text('Status', style: TextStyle(fontSize: 18),),
                    ],
                  ),
                ),
                Row(
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
                )
              ]),
        ),
      ),
    );
  }
}