import 'dart:convert';
import 'dart:io';
import 'package:dot_punch_list/DBProvider.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqlite_api.dart';
import 'create_edit_item.dart';
import 'entry.dart';
// import 'package:pdf/pdf.dart';
import 'package:open_file/open_file.dart';
import "dart:async";
// import 'package:image/image.dart';
// import 'report.dart';
import 'package:http/http.dart' as http;
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

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _providedByController = TextEditingController();
  Project project;
  List<Entry> entries = new List();
  bool _afaltoCheckBox = false;
  bool _concretoCheckBox = false;
  bool _pendingCheckBox = false;
  bool _doneCheckBox = false;
  
  _MyHomePageState({this.project});

  @override
  void initState() {
    _loadEntries();
    super.initState();
  }

  void _goToCreateItemPage(entry) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => CreateEditItem(project: project, entries: entries, entry: entry)));
  }

  void _loadEntries() async {
    DatabaseHelper dbHelper = DatabaseHelper.instance;
    Database db = await dbHelper.database;
    List<Map> maps = await db.query("Entries", where: "project = ?", whereArgs: [project.Id]);
    if (maps.length > 0) {
      setState(() {
        entries = maps.map((map) => Entry.fromJson(map)).toList();
      });
    }
  }

  void _filterEntries() async {
    String query = "";
    elements.forEach((element) {
      if (element.Selected == true) {
        var index = element.Element.index;
        query += query.isEmpty ? "element = $index" : " OR element = $index";
      }
    });
    if (_pendingCheckBox == true) query += query.isEmpty ? "status = 0" : " OR status = 0";
    if (_doneCheckBox == true) query += query.isEmpty ? "status = 1" : " OR status = 1";

    if (_providedByController.text.isNotEmpty) {
      if (query.isNotEmpty) query += " OR ";
      query += "providedBy LIKE '%${_providedByController.text}%'";
    }

    if (query.isEmpty) return _loadEntries();
    DatabaseHelper dbHelper = DatabaseHelper.instance;
    Database db = await dbHelper.database;
    List<Map> maps = await db.rawQuery("SELECT * FROM Entries WHERE (${query}) AND (project = ${project.Id})");
    setState(() {
      entries = maps.map((map) => Entry.fromJson(map)).toList();
    });
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
    var response = await http.post('https://dot-punch-list.herokuapp.com/pdf', body: {'entriesJson': json.encode(entriesJson), 'project': json.encode({'name': project.Name, 'description': project.Description})});
    List<int> pdfDataBytes = base64.decode(response.body);
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = "${tempDir.path}/report.pdf";
    final File file = File(tempPath);
    file.writeAsBytesSync(pdfDataBytes);
    Navigator.pop(context);
    OpenFile.open(file.path);
  }

  void _removeEntry(int index) async {
    DatabaseHelper dbHelper = DatabaseHelper.instance;
    await dbHelper.delete(entries[index].Id, "Entries");
    setState(() => entries.removeAt(index));
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
      endDrawer: Drawer(
        child: ListView(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 10, bottom: 10),
              child: TextField(
                decoration: InputDecoration(
                    labelText: "Provide By"
                ),
                controller: _providedByController,
              ),
            ),
            Divider(),
            Container(
              margin: EdgeInsets.only(left: 10, top: 10, bottom: 10),
              child: Text("Elements", style: TextStyle(fontSize: 18),),
            ),
            Divider(),
            Column(
              children: elements.map((element) {
                return ListTile(
                  title: Row(
                    children: <Widget>[
                      Checkbox(
                        value: element.Selected,
                      ),
                      Text(element.Name)
                    ],
                  ),
                  onTap: () => setState(() => element.Selected = !element.Selected),
                );
              }).toList(),
            ),
            Divider(),
            Container(
              margin: EdgeInsets.only(left: 10, top: 10, bottom: 10),
              child: Text("Status", style: TextStyle(fontSize: 18),),
            ),
            Divider(),
            Column(
              children: <Widget>[
                ListTile(
                  title: Row(
                    children: <Widget>[
                      Checkbox(
                        value: _pendingCheckBox,
                      ),
                      Text('Pending')
                    ],
                  ),
                  onTap: () {
                    // Navigator.pop(context);
                    setState(() => _pendingCheckBox = !_pendingCheckBox);
                  },
                ),
                ListTile(
                  title: Row(
                    children: <Widget>[
                      Checkbox(
                        value: _doneCheckBox,
                      ),
                      Text('Done')
                    ],
                  ),
                  onTap: () {
                    // Navigator.pop(context);
                    setState(() => _doneCheckBox = !_doneCheckBox);
                  },
                )
              ],
            ),
            RaisedButton(
              child: Text("Search"),
              onPressed: _filterEntries,
            )
          ],
        ),
      ),
      body: Container(
        child: entries.length > 0 ? ListView.builder(
          itemCount: entries.length,
          itemBuilder: (context, index) {
            return Dismissible(
              key: Key(entries[index].Id.toString()),
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
                        Text("Element: ", style: TextStyle(fontWeight: FontWeight.bold),),
                        Text("${entries[index].element}"),
                        Text(" Status: ", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("${entries[index].status}")
                      ],
                    ),
                    Text("By ${entries[index].ProvidedBy} on ${DateFormat.yMMMMEEEEd().format(entries[index].Time)}")
                  ],
                ),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EntryDisplay(project: project, entries: entries, entry: entries[index]))),
                leading: CircleAvatar(backgroundImage: FileImage(entries[index].Images[0])),
                // trailing: IconButton(icon: Icon(Icons.edit), onPressed: () => _goToCreateItemPage(entries[index])),
              ),
            );
          },
        ) : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Nothing to see here...',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 22
                  ),
                )
              ],
            )
          ],
        ),
      ),
      floatingActionButton: !project.Inactive ? FloatingActionButton(
        tooltip: 'Increment',
        onPressed: () => _goToCreateItemPage(null),
        child: Icon(Icons.add),
      ) : null, // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}