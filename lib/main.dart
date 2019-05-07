import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'projects.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
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
        primarySwatch: Colors.blue,
        accentColor: Colors.lightBlue[600],
      ),
      home: Projects(),
    );
  }
}
