import 'package:dot_punch_list/provided.dart';
import 'package:flutter/material.dart';
import 'element.dart';
import 'entry.dart';
import 'project.dart';
import 'create_edit_item.dart';
import 'package:url_launcher/url_launcher.dart';

class EntryDisplay extends StatefulWidget {

  Project project;
  List<Entry> entries;
  Entry entry;
  EntryBloc entryBloc;
  ProvidedBloc _providedBloc;
  ElementBloc _elementBloc;

  EntryDisplay(this.project, this.entries, this.entry, this.entryBloc, this._providedBloc, this._elementBloc);

  @override
  State<StatefulWidget> createState() => _EntryDisplay(project, entries, entry, entryBloc, _providedBloc, _elementBloc);
}

class _EntryDisplay extends State<EntryDisplay> {

  ProvidedBloc _providedBloc;
  ElementBloc _elementBloc;
  Project project;
  List<Entry> entries;
  Entry entry;
  EntryBloc entryBloc;

  _EntryDisplay(this.project, this.entries, this.entry, this.entryBloc, this._providedBloc, this._elementBloc);

  _launchMaps(lat, lng) async {
//    String googleUrl =
//        'comgooglemaps://?center=$lat,$lng';
  String googleUrl = "google.navigation:q=$lat,$lng";
    String appleUrl =
        'https://maps.apple.com/?sll=$lat,$lng';
    if (await canLaunch("comgooglemaps://")) {
      await launch(googleUrl);
    } else if (await canLaunch(appleUrl)) {
      await launch(appleUrl);
    } else {
      throw 'Could not launch url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Entry"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("Project", style: TextStyle(fontSize: 12),),
              Text(project.Name, style: TextStyle(fontSize: 18)),
              Divider(),
              Container(
                child: project.Description != null && project.Description.isNotEmpty ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("Description", style: TextStyle(fontSize: 12),),
                    Text(project.Description, style: TextStyle(fontSize: 18)),
                    Divider(),
                  ],
                ) : null,
              ),
              Text("Category", style: TextStyle(fontSize: 12),),
              Text(entry.element, style: TextStyle(fontSize: 18)),
              Divider(),
              Text("Location", style: TextStyle(fontSize: 12),),
              Text(entry.Location, style: TextStyle(fontSize: 18)),
              Divider(),
              Container(
                child: entry.Coordinates != null ? Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("Coordinates", style: TextStyle(fontSize: 12),),
                              Text(entry.Coordinates.toString(), style: TextStyle(fontSize: 18)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.navigation),
                          onPressed: () => _launchMaps(entry.Coordinates.Latitude, entry.Coordinates.Longitude),
                          color: Colors.green,
                        )
                      ],
                    ),
                    Divider()
                  ],
                ) : null,
              ),
              Text("Issue", style: TextStyle(fontSize: 12),),
              Text(entry.Issue, style: TextStyle(fontSize: 18)),
              Divider(),
              Text("Provided By", style: TextStyle(fontSize: 12),),
              Text(entry.ProvidedBy.Name, style: TextStyle(fontSize: 18)),
              Divider(),
              Text("Before Image", style: TextStyle(fontSize: 12)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: entry.Images.isNotEmpty ? Card(
                      semanticContainer: true,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 5,
                      margin: EdgeInsets.all(10),
                      child: Image.file(entry.Images[0], fit: BoxFit.fill,),
                    ) : Text("N/A", style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
              Divider(),
              Text("Status", style: TextStyle(fontSize: 12),),
              Text(entry.status, style: TextStyle(fontSize: 18),),
              Divider(),
              Container(
                child: entry.Status == StatusEnum.done ? Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text("After Image", style: TextStyle(fontSize: 12),),
                      ],
                    ),
                    entry.DoneImages.isNotEmpty ? Card(
                      semanticContainer: true,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 5,
                      margin: EdgeInsets.all(10),
                      child: Image.file(entry.DoneImages[0], fit: BoxFit.fill,),
                    ) : Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[Text("N/A", style: TextStyle(fontSize: 18),)],),
                    Container(
                      child: entry.Remarks != null && entry.Remarks.isNotEmpty ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Divider(),
                          Text("Remark", style: TextStyle(fontSize: 12),),
                          Text(entry.Remarks, style: TextStyle(fontSize: 18),)
                        ],
                      ) : null,
                    )
                  ],
                ) : null,
              )
            ],
          ),
        ),
      ),
      floatingActionButton: !project.Inactive ? FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CreateEditItem(project, entries, entry, entryBloc, _providedBloc, _elementBloc))),
        child: Icon(Icons.edit),
      ) : null,
    );
  }
}