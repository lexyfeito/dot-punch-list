import 'dart:io';
import 'package:dot_punch_list/DBProvider.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqlite_api.dart';
import 'create_edit_item.dart';
import 'entry.dart';
import 'package:pdf/pdf.dart';
import 'package:open_file/open_file.dart';
import "dart:async";
import 'package:image/image.dart';
import 'report.dart';

class MyHomePage extends StatefulWidget {
  final String title;
  final List<Entry> entries;

  MyHomePage({Key key, this.title, this.entries}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState(entries: entries);
}

class _MyHomePageState extends State<MyHomePage> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Entry> entries;
  bool _afaltoCheckBox = false;
  bool _concretoCheckBox = false;
  bool _pendingCheckBox = false;
  bool _doneCheckBox = false;
  
  _MyHomePageState({this.entries}) {
  }

  @override
  void initState() {
    _loadEntries();
    super.initState();
  }

  void _goToCreateItemPage(entry) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => CreateEditItem(entries: entries, entry: entry)));
  }

  void _loadEntries() async {
    DatabaseHelper dbHelper = DatabaseHelper.instance;
    Database db = await dbHelper.database;
    List<Map> maps = await db.query("Entries");
    if (maps.length > 0) {
      setState(() {
        entries = maps.map((map) => Entry.fromJson(map)).toList();
      });
    }
    return null;
  }

  void _filterEntries() async {
    String query = "";
    if (_afaltoCheckBox == true) query += "element = 0";
    if (_concretoCheckBox == true) query += query.isEmpty ? "element = 1" : " OR element = 1";
    if (_pendingCheckBox == true) query += query.isEmpty ? "status = 0" : " OR status = 0";
    if (_doneCheckBox == true) query += query.isEmpty ? "status = 1" : " OR status = 1";
    if (query.isEmpty) return _loadEntries();
    DatabaseHelper dbHelper = DatabaseHelper.instance;
    Database db = await dbHelper.database;
    List<Map> maps = await db.rawQuery("SELECT * FROM Entries WHERE ${query}");
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
          child: new Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              new CircularProgressIndicator(),
              new Text("Loading"),
            ],
          ),
        );
      },
    );
  }

  void _createReport() async {
    var report = new Report();
    var file = await report.createReport(entries);
    OpenFile.open(file.path);
//    if (entries.isEmpty) return;
//    final pdf = PdfDocument(deflate: zlib.encode);
//    entries.forEach((Entry entry) {
//      final page = PdfPage(pdf, pageFormat: PdfPageFormat.letter);
//      final g = page.getGraphics();
//      final font = g.defaultFont;
//      final top = page.pageFormat.height;
//
//      g.setColor(PdfColor(0.3, 0.3, 0.3));
//      g.drawString(font, 12.0, "Element: ${entry.element}", 10.0 * PdfPageFormat.mm,
//          top - 10.0 * PdfPageFormat.mm);
//
//      g.setColor(PdfColor(0.3, 0.3, 0.3));
//      g.drawString(font, 12.0, "Title: ${entry.Title}", 10.0 * PdfPageFormat.mm,
//          top - 20.0 * PdfPageFormat.mm);
//
//      g.setColor(PdfColor(0.3, 0.3, 0.3));
//      g.drawString(font, 12.0, "Comment: ${entry.Comments}", 10.0 * PdfPageFormat.mm,
//          top - 30.0 * PdfPageFormat.mm);
//
//      g.setColor(PdfColor(0.3, 0.3, 0.3));
//      g.drawString(font, 12.0, "Location: ${entry.Location}", 10.0 * PdfPageFormat.mm,
//          top - 40.0 * PdfPageFormat.mm);
//
//      var offset = 0;
//      entry.Images.forEach((File file) {
//        var img = decodeImage(file.readAsBytesSync());
//        PdfImage image = PdfImage(
//            pdf,
//            image: img.data.buffer.asUint8List(),
//            width: img.width,
//            height: img.height);
//        g.drawImage(image, 10.0 + offset * PdfPageFormat.mm, top - image.height / PdfPageFormat.mm, 80.0);
//        offset += 45;
//      });
//
//      g.setColor(PdfColor(0.3, 0.3, 0.3));
//      g.drawString(font, 12.0, "Status: ${entry.status}", 10.0 * PdfPageFormat.mm,
//          top - 100.0 * PdfPageFormat.mm);
//    });
//
//    Directory tempDir = await getTemporaryDirectory();
//    String tempPath = "${tempDir.path}/report.pdf";
//    var file = File(tempPath);
//    await file.writeAsBytes(pdf.save());
//    OpenFile.open(file.path);
  }

  void _removeEntry(int index) async {
    DatabaseHelper dbHelper = DatabaseHelper.instance;
    await dbHelper.delete(entries[index].Id);
    setState(() => entries.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(widget.title),
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
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(10.0),
                    child: Text(
                      'Elements',
                      style: TextStyle(
                          fontSize: 18
                      ),
                    ),
                  ),
                  ListTile(
                    title: Row(
                      children: <Widget>[
                        Checkbox(
                          value: _afaltoCheckBox,
                        ),
                        Text('Afalto')
                      ],
                    ),
                    onTap: () {
                      // Navigator.pop(context);
                      setState(() => _afaltoCheckBox = !_afaltoCheckBox);
                    },
                  ),
                  ListTile(
                    title: Row(
                      children: <Widget>[
                        Checkbox(
                          value: _concretoCheckBox,
                        ),
                        Text('Concreto')
                      ],
                    ),
                    onTap: () {
                      // Navigator.pop(context);
                      setState(() => _concretoCheckBox = !_concretoCheckBox);
                    },
                  ),
                  Container(
                    margin: EdgeInsets.all(10.0),
                    child: Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
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
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    child: Text("Search"),
                    onPressed: () { _filterEntries(); },
                  ),
                )
              ],
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
                title: Text(entries[index].Title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(entries[index].Comments),
                    Text("Element: ${entries[index].element} Status: ${entries[index].status}")
                  ],
                ),
                onTap: () => _goToCreateItemPage(entries[index]),
                leading: CircleAvatar(backgroundImage: FileImage(entries[index].Images[0])),
                trailing: entries[index].Status == StatusEnum.done ? Icon(Icons.done) : null,
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
                    color: Colors.black,
                    fontSize: 22
                  ),
                )
              ],
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Increment',
        onPressed: () => _goToCreateItemPage(null),
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}