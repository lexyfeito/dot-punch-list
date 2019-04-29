import 'package:flutter/material.dart';
import 'home.dart';
import 'entry.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  List<Entry> entries = new List();

  @override
  void initState() {
    _requestPermissions();
    super.initState();
  }

  _requestPermissions() async {
    var permission = await PermissionHandler().requestPermissions([PermissionGroup.location]);
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DOT Punch List',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        accentColor: Colors.lightBlue[600],
      ),
      home: MyHomePage(title: 'DOT Punch List', entries: entries),
    );
  }
}
