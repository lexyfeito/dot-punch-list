import 'package:dot_punch_list/provided.dart';
import 'package:flutter/material.dart';

class ProvidedByNewDialog extends StatefulWidget {
  ProvidedBloc _providedBloc;
  ProvidedByNewDialog(this._providedBloc);

  @override
  State<StatefulWidget> createState() => _ProvidedByNewDialog(_providedBloc);
}

class _ProvidedByNewDialog extends State<ProvidedByNewDialog> {
  final _providedByFormKey = GlobalKey<FormState>();
  ProvidedBloc _providedBloc;
  var newProvidedBy = TextEditingController();

  _ProvidedByNewDialog(this._providedBloc);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: <Widget>[
        FlatButton(
          child: Text("Save"),
          onPressed: () {
            if (!_providedByFormKey.currentState.validate()) return;
            _providedBloc.providedEventSink.add(AddProvidedEvent(new ProvidedModel(Name: newProvidedBy.text)));
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