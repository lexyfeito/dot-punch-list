import 'package:flutter/material.dart';
import 'package:sqflite/sqlite_api.dart';
import 'DBProvider.dart';
import 'disclaimer_popup.dart';
import 'models/settings.dart';
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
    _init();
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

  void _removeProject(Project project) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Remove?'),
          content: Text('Would you like to permanently remove ${project.Name}?'),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            FlatButton(
              child: Text("Remove"),
              onPressed: () async {
                DatabaseHelper dbHelper = DatabaseHelper.instance;
                Database db = await dbHelper.database;
                await db.rawUpdate("DELETE FROM Projects WHERE id = ?", [project.Id]);
                Navigator.pop(context);
                _loadProjects();
              },
              textColor: Colors.red,
            ),
          ],
        );
      }
    );
  }

  void _showDeleteDialog(Project project) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Text("Deactivate ${project.Name}?"),
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
            ),
          ],
        );
      },
    );
  }

  _showReactivateDialog(Project project) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Text("Activate ${project.Name}?"),
          content: Text("Are you sure you would like to re-activate this project?"),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            FlatButton(
              child: Text("Make Activate"),
              onPressed: () async {
                DatabaseHelper dbHelper = DatabaseHelper.instance;
                Database db = await dbHelper.database;
                await db.rawUpdate("UPDATE Projects set inactive = 0 WHERE id = ?", [project.Id]);
                Navigator.pop(context);
                _loadProjects();
              },
              textColor: Colors.red,
            ),
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
                    : IconButton(icon: Icon(Icons.delete), onPressed: () => _removeProject(projects[index]),),
                onLongPress: () => !_showInactive ? _showDeleteDialog(projects[index]) : _showReactivateDialog(projects[index]),
              );
            }) : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("No available ${_showInactive ? 'inactive' : ''} projects", style: TextStyle(color: Colors.grey, fontSize: 22,),)
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

  _init() async {
    final _dbHelper = DatabaseHelper.instance;
    List<Map> settings = await _dbHelper.query('Settings');
    if (settings.isNotEmpty) {
      var setting = SettingsModel.fromJson(settings[0]);
      if (!setting.disclaimerClosed) {
        await showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return DisclaimerPopup();
            }
        );

        setting.disclaimerClosed = true;
        await _dbHelper.update(setting, 'Settings');
      }
    }
  }
}