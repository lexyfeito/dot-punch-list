import 'package:flutter/material.dart';
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
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DOT Punch List',
      theme: ThemeData(
        primaryColor: Colors.blue[600],
        accentColor: Colors.blue[600],
        errorColor: Colors.red[900]
      ),
      home: Projects(),
    );
  }
}
