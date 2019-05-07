import 'package:flutter/material.dart';
import 'package:sqflite/sqlite_api.dart';
import 'DBProvider.dart';
import 'project.dart';
import 'create_edit_project.dart';
import 'entries.dart';

class Projects extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _ProjectState();
}

class _ProjectState extends State<Projects> {

  List<Project> projects = new List();
  bool _showInactive = false;

  @override
  void initState() {
    _loadProjects();
    super.initState();
  }

  void _loadProjects() async {
    DatabaseHelper dbHelper = DatabaseHelper.instance;
    Database db = await dbHelper.database;
    List<Map> maps = await db.query("Projects", where: "inactive = ?", whereArgs: [_showInactive ? 1 : 0]);
    if (maps.length > 0) setState(() => projects = maps.map((map) => Project.fromJson(map)).toList());
    else setState(() => projects = new List());
  }

  void _showDeleteDialog(Project project) {
    if (_showInactive) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Text("Remove ${project.Name}?"),
          content: Text("Are you sure you would like to deactivate this project?"),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            FlatButton(
              child: Text("Deactivate"),
              onPressed: () async {
                DatabaseHelper dbHelper = DatabaseHelper.instance;
                Database db = await dbHelper.database;
                await db.rawUpdate("UPDATE Projects set inactive = 1 WHERE id = ?", [project.Id]);
                Navigator.pop(context);
                _loadProjects();
              },
              textColor: Colors.red,
            )
          ],
        );
      },
    );
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Projects"),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (value) {
              setState(() {
                _showInactive = value;
                _loadProjects();
              });
            },
            itemBuilder: (context) => [
              _showInactive ? PopupMenuItem(
                value: false,
                child: Text("Show actives")
              ) : PopupMenuItem(
                  value: true,
                  child: Text("Show inactives")
              ),
            ],
          )
        ],
      ),
      body: Container(
        child: projects != null && projects.length != 0 ? ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(projects[index].Name),
                  subtitle: projects[index].Description != null && projects[index].Description.isNotEmpty ?  Text(projects[index].Description) : null,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage(project: projects[index],))),
                  trailing: !_showInactive ? IconButton(icon: Icon(Icons.edit), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CreateEditProject(projects: projects, project: projects[index]))))
                  : Icon(Icons.not_interested),
                  onLongPress: () => _showDeleteDialog(projects[index]),
                );
              }) : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("No available projects", style: TextStyle(color: Colors.grey, fontSize: 22,),)
                    ],
                  )
                ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateEditProject(projects: projects)));
          setState(() {
            _showInactive = false;
            _loadProjects();
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}