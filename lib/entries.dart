import 'dart:convert';
import 'dart:io';
import 'package:dot_punch_list/provided.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'create_edit_item.dart';
import 'element.dart';
import 'entry.dart';
import 'package:open_file/open_file.dart';
import "dart:async";
import 'package:http/http.dart' as http;
import 'filter_drawer.dart';
import 'project.dart';
import 'entry_display.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {

  Project project;
  MyHomePage({Key key, this.project}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState(project: project);
}

class _MyHomePageState extends State<MyHomePage> {

  final _entryBloc = EntryBloc();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Project project;
  List<Entry> entries = new List();
  var _providedByBloc = ProvidedBloc();
  var _elementBloc = ElementBloc();
  var _filterModel = FilterModel(false, false, false);

  _MyHomePageState({this.project});

  @override

  void initState() {
    super.initState();
    _entryBloc.entryEventSink.add(GetEntries(project));
    _providedByBloc.providedEventSink.add(GetProvidedEvent(project));
    _elementBloc.elementEventSink.add(GetElements());
  }

  void _goToCreateItemPage(entry) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => CreateEditItem(project, entries ,entry, _entryBloc, _providedByBloc, _elementBloc)));
  }


  Future _showLoader(context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          child: Container(
            margin: EdgeInsets.all(20),
            child: Row(
              children: [
                CircularProgressIndicator(),
                Container(
                  margin: EdgeInsets.only(left: 15),
                  child: Text("Please wait..."),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _createReport() async {
    _showLoader(context);
    var entriesJson = entries.map((Entry entry) => entry.toJson2()).toList();
    // http://10.0.0.134:8080/pdf
    // https://dot-punch-list.herokuapp.com/pdf
    try {
      var response = await http.post('https://dot-punch-list.herokuapp.com/pdf', body: {'entriesJson': json.encode(entriesJson), 'project': json.encode({'name': project.Name, 'description': project.Description})});
      List<int> pdfDataBytes = base64.decode(response.body);
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = "${tempDir.path}/report.pdf";
      final File file = File(tempPath);
      file.writeAsBytesSync(pdfDataBytes);
      Navigator.pop(context);
      OpenFile.open(file.path);
    } catch (e) {
      Navigator.pop(context);
    }
  }

  void _removeEntry(int index) async {
    _entryBloc.entryEventSink.add(RemoveEntry(entries[index].Id));
  }

  @override
  void dispose() {
    super.dispose();
    _entryBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
//        automaticallyImplyLeading: false,
        title: Text("Entries"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.pie_chart),
            onPressed: () => _createReport(),
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => _scaffoldKey.currentState.openEndDrawer(),
          ),
        ],
      ),
      endDrawer: FilterDrawer(project, _entryBloc, _providedByBloc, _elementBloc, _filterModel),
      body: Container(
        child: StreamBuilder(
          stream: _entryBloc.entries,
          builder: (BuildContext context, AsyncSnapshot<List<Entry>> snapshot) {
            if (snapshot.data == null || snapshot.data.isEmpty)
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Nothing to see here',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 22
                        ),
                      )
                    ],
                  )
                ],
              );

            entries = snapshot.data;
            return ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(entries[index].Id.toString()),
                  confirmDismiss: (direction) {
                    return showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Remove'),
                          content: Text('This item will be removed. Are you sure?'),
                          actions: <Widget>[
                            FlatButton(
                              child: Text('Cancel'),
                              onPressed: () => Navigator.of(context).pop(false),
                            ),
                            FlatButton(
                              child: Text('Remove'),
                              onPressed: () => Navigator.of(context).pop(true),
                              textColor: Colors.red,
                            )
                          ],
                        );
                      }
                    );
                  },
                  onDismissed: (direction) {
                    _removeEntry(index);
                  },
                  child: ListTile(
                    isThreeLine: true,
                    title: Text(entries[index].Issue),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text("Category: ", style: TextStyle(fontWeight: FontWeight.bold),),
                            Text("${entries[index].element}"),
                            Text(" Status: ", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text("${entries[index].status}")
                          ],
                        ),
                        Text("By ${entries[index].ProvidedBy.Name} on ${DateFormat.yMMMMEEEEd().format(entries[index].Time)}")
                      ],
                    ),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EntryDisplay(project, entries, entries[index], _entryBloc, _providedByBloc, _elementBloc))),
                    leading: CircleAvatar(
                      backgroundImage: entries[index].Images != null && entries[index].Images.isNotEmpty ? FileImage(entries[index].Images[0]) : null,
                      child: entries[index].Images != null && entries[index].Images.isNotEmpty ? Text("") : Text("N/A"),
                    ),
                    // trailing: IconButton(icon: Icon(Icons.edit), onPressed: () => _goToCreateItemPage(entries[index])),
                  ),
                );
              },
            );
          },
        )
      ),
      floatingActionButton: !project.Inactive ? FloatingActionButton(
        tooltip: 'Increment',
        onPressed: () => _goToCreateItemPage(null),
        child: Icon(Icons.add),
      ) : null, // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}