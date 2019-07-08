import 'dart:io';

import 'package:dot_punch_list/DBProvider.dart';
import 'package:dot_punch_list/provided.dart';
import 'package:dot_punch_list/provided_by_new_dialog.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'element.dart';
import 'elements.dart';
import 'entry.dart';
import 'project.dart';
import 'package:image/image.dart';

class CreateEditItem extends StatefulWidget {

  ProvidedBloc _providedBloc;
  ElementBloc _elementBloc;
  final List<Entry> entries;
  final Project project;
  final Entry entry;
  final EntryBloc entryBloc;

  CreateEditItem(this.project, this.entries, this.entry, this.entryBloc, this._providedBloc, this._elementBloc, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CreateEditItemState(project, entries, entry, entryBloc, _providedBloc, _elementBloc);
}

class _CreateEditItemState extends State<CreateEditItem> {

  ProvidedBloc _providedBloc;
  ElementBloc _elementBloc;
  bool isEditing = false;
  Project project;
  List<Entry> entries;
  Entry entry;
  EntryBloc entryBloc;
  Entry newEntry;
  DatabaseHelper _dbHelper;
  int selectedElementId;
  int selectedProvidedId;
  var titleController = TextEditingController();
  var descriptionController = TextEditingController();
  var commentController = TextEditingController();
  var remarkController = TextEditingController();
  var locationController = TextEditingController();
  var issueController = TextEditingController();
  var latCoordController = TextEditingController();
  var lngCoordController = TextEditingController();
  var providerByController = TextEditingController();
  var newProvidedBy = TextEditingController();

  _CreateEditItemState(this.project, this.entries, this.entry, this.entryBloc, this._providedBloc, this._elementBloc) {
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
    super.initState();
    _elementBloc.elementEventSink.add(null);
    _providedBloc.providedEventSink.add(null);
    _dbHelper = DatabaseHelper.instance;
    if (newEntry.Element != null)
      selectedElementId = newEntry.Element.Id;
    if (newEntry.ProvidedBy != null)
      selectedProvidedId = newEntry.ProvidedBy.Id;
    locationController.text = newEntry.Location;
    titleController.text = newEntry.Title;
    commentController.text = newEntry.Comments;
    remarkController.text = newEntry.Remarks;
    issueController.text = newEntry.Issue;
    if (newEntry.Coordinates != null) {
      latCoordController.text = newEntry.Coordinates.Latitude.toString();
      lngCoordController.text = newEntry.Coordinates.Longitude.toString();
    }
  }

  Future<File> getImage(ImageSource source) async {
    var image = await ImagePicker.pickImage(source: source, maxWidth: 500);

    return image;
  }

  _openCamera() {
    getImage(ImageSource.camera);
  }

  Future<File> _openGallery() async {
    var image = await getImage(ImageSource.gallery);

    return image;
  }

  bool isImage(File image) {
    var ext = image.path.substring(image.path.lastIndexOf('.'));
    return ext == '.png' || ext == '.jpg' || ext == '.jpeg';
  }

  Future _copyFiles(List<File> images, List<File> from, List<File> contains) async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path;
    for (File image in from) {
      if (isEditing && contains.map((File e) => e.path).contains(image.path)) continue;
      var name = image.path.substring(image.path.lastIndexOf('/'));
//      var decodedImage = decodeImage(image.readAsBytesSync());
//      var thumbnail = copyResize(decodedImage, width: 300);
//      File newFile = File('$path$name')..writeAsBytesSync(encodeJpg(thumbnail));
      var newFile = await image.copy('$path$name');
      images.length > 0 ? images[0] = newFile : images.add(newFile);
    }

    return images;
  }

  Future _save() async {
    if (!_formKey.currentState.validate() || selectedElementId == null || selectedProvidedId == null || newEntry.Status == null) return;

    List<File> newImagesList = isEditing ? entry.Images : new List<File>();
    List<File> newDoneImagesList = isEditing ? entry.DoneImages : new List<File>();
    newImagesList = await _copyFiles(newImagesList, newEntry.Images, isEditing ? entry.Images : null);
    if (newEntry.Status == StatusEnum.done) {
      newDoneImagesList = await _copyFiles(newDoneImagesList, newEntry.DoneImages, isEditing ? entry.DoneImages : null);
    }

    if (!isEditing) {
      _updateEntry(newEntry, newImagesList, newDoneImagesList);
      newEntry.Time = new DateTime.now();
      entryBloc.entryEventSink.add(AddEntry(newEntry));
    } else {
      _updateEntry(entry, newImagesList, newDoneImagesList);
      entry.Status = newEntry.Status;
      entryBloc.entryEventSink.add(EditEntry(entry));
    }
    Navigator.pop(context);
  }

  _updateEntry(Entry e, imageList, doneImageList) {
    e.Element = _elementBloc.elementsList.firstWhere((element) => element.Id == selectedElementId);
    e.Location = locationController.text;
    if ((latCoordController.text != null && latCoordController.text.isNotEmpty) && (lngCoordController.text != null && lngCoordController.text.isNotEmpty))
      e.Coordinates = new CoordinatesModel(double.parse(latCoordController.text), double.parse(lngCoordController.text));
    e.Title = titleController.text;
    e.Comments = commentController.text;
    e.Issue = issueController.text;
    e.Images = imageList;
    e.DoneImages = doneImageList;
    e.Remarks = remarkController.text;
    e.ProjectModel = project;
    // e.ProvidedBy = providerByController.text;
    e.ProvidedBy = _providedBloc.providedList.firstWhere((provided) => provided.Id == selectedProvidedId);
  }

  final _formKey = GlobalKey<FormState>();
  final _providedByFormKey = GlobalKey<FormState>();

  String _fileName(File file) {
    return file.path.substring(file.path.lastIndexOf('/') + 1);
  }

  @override
  void dispose() {
    super.dispose();
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
                                child: StreamBuilder(
                                  stream: _elementBloc.elements,
                                  builder: (BuildContext context, AsyncSnapshot<List<ElementModel>> snapshot) {
                                    if (snapshot.data == null) return Text("");
                                    return DropdownButtonFormField(
                                      value: selectedElementId,
                                      items: snapshot.data.map((element) {
                                        return DropdownMenuItem(
                                          value: element.Id,
                                          child: Text(element.Name),
                                        );
                                      }).toList(),
                                      decoration: InputDecoration(
                                        labelText: 'Categories'
                                      ),
                                      onChanged: (value) {
                                        setState(() => selectedElementId = value);
                                      },
                                      validator: (value) {
                                        if (value == null) {
                                          return 'Required field.';
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),
                              Container(
                                child: IconButton(
                                  icon: Icon(Icons.add),
                                  color: Colors.green,
                                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Elements(_elementBloc))),
                                ),
                                margin: EdgeInsets.only(left: 20),
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
                                      labelText: 'Latitude',
                                    ),
                                    controller: latCoordController,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(left: 10),
                                  child: TextFormField(
                                      decoration: InputDecoration(
                                        labelText: 'Longitude',
                                      ),
                                      controller: lngCoordController,
                                  ),
                                ),
                              ),
                              Container(
                                child: IconButton(
                                  color: Colors.green,
                                  icon: Icon(Icons.location_on),
                                  onPressed: () async {
//                                    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//                                    setState(() {
//                                      latCoordController.text = position.latitude.toString();
//                                      lngCoordController.text = position.longitude.toString();
//                                    });

                                    var location = new Location();
                                    LocationData userLocation;
                                    userLocation = await location.getLocation();
                                    setState(() {
                                      latCoordController.text = userLocation.latitude.toString();
                                      lngCoordController.text = userLocation.longitude.toString();
                                    });
                                  },
                                ),
                                margin: EdgeInsets.only(left: 20),
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
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: StreamBuilder(
                                    stream: _providedBloc.provided,
                                    builder: (BuildContext context, AsyncSnapshot<List<ProvidedModel>> snapshot) {
                                      return DropdownButtonFormField(
                                        value: selectedProvidedId,
                                        items: snapshot.data != null ? snapshot.data.map((i) => DropdownMenuItem(child: Text(i.Name), value: i.Id)).toList() : [],
                                        decoration: InputDecoration(
                                            labelText: "Provided By"
                                        ),
                                        validator: (value) {
                                          if (value == null)
                                            return 'Required field.';
                                        },
                                        onChanged: (value) {
                                          setState(() => selectedProvidedId = value);
                                        },
                                      );
                                    },
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 20),
                                  child: IconButton(
                                    icon: Icon(Icons.add),
                                    color: Colors.green,
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return ProvidedByNewDialog(_providedBloc);

                                        }
                                      );
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Text('Before Image', style: TextStyle(
                          fontSize: 12
                      )),
                      margin: EdgeInsets.only(bottom: 5, left: 5),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10, right: 10),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: FlatButton(
                              textTheme: ButtonTextTheme.accent,
                              child: Text('Select Before Image'),
                              onPressed: () async {
                                var image = await _openGallery();
                                if (image != null && isImage(image)) {
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
                          Text('Status', style: TextStyle(fontSize: 12)),
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
                          Radio(
                            value: StatusEnum.no_action,
                            groupValue: newEntry.Status,
                            onChanged: (value) {
                              setState(() {
                                newEntry.Status = value;
                              });
                            },
                          ),
                          Text('No Action')
                        ],
                      ),
                    ),
                    Container(
                      child: Text('After Image', style: TextStyle(
                          fontSize: 12
                      )),
                      margin: EdgeInsets.only(bottom: 5, left: 5),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10, right: 10),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: FlatButton(
                              textTheme: ButtonTextTheme.accent,
                              child: Text('Select After Image'),
                              onPressed: newEntry.Status == StatusEnum.done ? () async {
                                var image = await _openGallery();
                                if (image != null && isImage(image)) {
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