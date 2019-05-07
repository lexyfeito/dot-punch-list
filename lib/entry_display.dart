import 'package:flutter/material.dart';
import 'entry.dart';
import 'project.dart';
import 'create_edit_item.dart';

class EntryDisplay extends StatefulWidget {

  Project project;
  List<Entry> entries;
  Entry entry;

  EntryDisplay({this.project, this.entries, this.entry});

  @override
  State<StatefulWidget> createState() => _EntryDisplay(project: project, entries:  entries, entry: entry);
}

class _EntryDisplay extends State<EntryDisplay> {

  Project project;
  List<Entry> entries;
  Entry entry;

  _EntryDisplay({this.project, this.entries, this.entry});

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
              Text("Element", style: TextStyle(fontSize: 12),),
              Text(entry.element, style: TextStyle(fontSize: 18)),
              Divider(),
              Text("Location", style: TextStyle(fontSize: 12),),
              Text(entry.Location, style: TextStyle(fontSize: 18)),
              Divider(),
              Container(
                child: entry.Coordinates != null && entry.Coordinates.isNotEmpty ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("Coordinates", style: TextStyle(fontSize: 12),),
                    Text(entry.Coordinates, style: TextStyle(fontSize: 18)),
                    Divider(),
                  ],
                ) : null,
              ),
              Text("Issue", style: TextStyle(fontSize: 12),),
              Text(entry.Issue, style: TextStyle(fontSize: 18)),
              Divider(),
              Text("Provided By", style: TextStyle(fontSize: 12),),
              Text(entry.ProvidedBy, style: TextStyle(fontSize: 18)),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Before Image", style: TextStyle(fontWeight: FontWeight.bold),),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Card(
                      semanticContainer: true,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 5,
                      margin: EdgeInsets.all(10),
                      child: Image.file(entry.Images[0], fit: BoxFit.fill,),
                    ),
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
                    Text("After Image", style: TextStyle(fontWeight: FontWeight.bold),),
                    Card(
                      semanticContainer: true,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 5,
                      margin: EdgeInsets.all(10),
                      child: Image.file(entry.DoneImages[0], fit: BoxFit.fill,),
                    ),
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
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CreateEditItem(project: project, entries: entries, entry: entry))),
        child: Icon(Icons.edit),
      ) : null,
    );
  }
}