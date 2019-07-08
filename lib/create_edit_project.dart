import 'package:dot_punch_list/DBProvider.dart';
import 'package:flutter/material.dart';
import 'project.dart';

class CreateEditProject extends StatefulWidget {
  List<Project> projects;
  Project project;

  CreateEditProject({this.projects, this.project});

  @override
  State<StatefulWidget> createState() => _CreateEditProjectState(projects: projects, project: project);
}

class _CreateEditProjectState extends State<CreateEditProject> {
  List<Project> projects;
  Project project;
  Project newProject;
  bool _isEditing = false;
  DatabaseHelper _dbHelper;
  var nameController = TextEditingController();
  var descriptionController = TextEditingController();

  _CreateEditProjectState({this.projects, this.project}) {
    if (project != null) {
      _isEditing = true;
      newProject = new Project(
        Id: project.Id,
        Name: project.Name,
        Description: project.Description
      );
    } else newProject = new Project();
  }

  @override
  void initState() {
    _dbHelper = DatabaseHelper.instance;
    nameController.text = newProject.Name;
    descriptionController.text = newProject.Description;
  }

  _save() async {
    if (!_formKey.currentState.validate()) return;
    if (_isEditing) {
      project.Name = nameController.text;
      project.Description = descriptionController.text;
      await _dbHelper.update(project, "Projects");
    } else {
      newProject.Name = nameController.text;
      newProject.Description = descriptionController.text;
      newProject.Inactive = false;
      newProject.Id = await _dbHelper.insert(newProject, "Projects");
      projects.add(newProject);
    }

    Navigator.pop(context);
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? "Edit Project" : "New Project"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () => _save(),
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter the name';
                  }
                },
                controller: nameController,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Description',
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                controller: descriptionController,
              ),
            ],
          ),
        ),
      ),
    );
  }
}