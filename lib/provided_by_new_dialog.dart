import 'package:dot_punch_list/project.dart';
import 'package:dot_punch_list/provided.dart';
import 'package:flutter/material.dart';

class ProvidedByNewDialog extends StatefulWidget {

  ProvidedBloc _providedBloc;
  ProvidedModel providedBy;
  Project project;

  ProvidedByNewDialog(this._providedBloc, this.project, {this.providedBy});

  @override
  State<StatefulWidget> createState() => _ProvidedByNewDialog(_providedBloc, project, providedBy: providedBy);
}

class _ProvidedByNewDialog extends State<ProvidedByNewDialog> {

  final _providedByFormKey = GlobalKey<FormState>();
  ProvidedBloc _providedBloc;
  var newProvidedBy = TextEditingController();
  ProvidedModel providedBy;
  bool isEditing = false;
  Project project;

  _ProvidedByNewDialog(this._providedBloc, this.project, {this.providedBy});

  @override
  void initState() {
    super.initState();
    if (providedBy != null) {
      newProvidedBy.text = providedBy.Name;
      isEditing = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: <Widget>[
        FlatButton(
          child: Text(isEditing ? "Edit" : "Save"),
          onPressed: () {
            if (!_providedByFormKey.currentState.validate()) return;
            if (!isEditing)
              _providedBloc.providedEventSink.add(AddProvidedEvent(new ProvidedModel(Name: newProvidedBy.text, ProjectId: project.Id, Inactive: false)));
            else {
              providedBy.Name = newProvidedBy.text;
              _providedBloc.providedEventSink.add(EditProvidedEvent(providedBy));
            }
            newProvidedBy.clear();
            Navigator.pop(context);
          },
        )
      ],
      content: Form(
          key: _providedByFormKey,
          child: TextFormField(
            controller: newProvidedBy,
            decoration: InputDecoration(
              labelText: "Provided By Name",
            ),
            validator: (value) {
              if (value.isEmpty) return "Required";
            },
          )
      ),
    );
  }
}