import 'package:flutter/material.dart';

import 'DBProvider.dart';
import 'element.dart';

class CreateEditElement extends StatefulWidget {

  ElementModel element;
  ElementBloc elementBloc;

  CreateEditElement(this.element, this.elementBloc) {}

  @override
  State<StatefulWidget> createState() => _CreateEditElement(element, elementBloc);
}

class _CreateEditElement extends State<CreateEditElement> {

  ElementModel element;
  ElementBloc elementBloc;
  ElementModel newElement;
  bool isEditing = false;
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final _dbHelper = DatabaseHelper.instance;

  _CreateEditElement(this.element, this.elementBloc) {
    if (element != null) {
      isEditing = true;
      nameController.text = element.Name;
      descriptionController.text = element.Description;
    } else {
      element = new ElementModel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isEditing ? Text("Edit Category") : Text("Add Category"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: ()  async {
              if (_formKey.currentState.validate()) {
                element.Name = nameController.text;
                element.Description = descriptionController.text;
                if (!isEditing) {
                  elementBloc.elementEventSink.add(AddElement(element));
                } else {
                  elementBloc.elementEventSink.add(EditElement(element));
                }
                Navigator.pop(context);
              }
            },
          )
        ],
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Name"
                ),
                controller: nameController,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Required field.';
                  }
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                    labelText: "Description"
                ),
                controller: descriptionController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
              )
            ],
          ),
        ),
      ),
    );
  }
}