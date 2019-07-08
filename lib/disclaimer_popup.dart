import 'package:flutter/material.dart';

class DisclaimerPopup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Disclaimer'),
      content: Text('Be advised that any data saved by this application is saved locally in your device/phone. Uninstalling the application will result in the removal of the data. We are working on a premium plan where you will be able to back up your data in the cloud. Hang in there!'),
      actions: <Widget>[
        FlatButton(
          child: Text('Agree'),
          onPressed: () => Navigator.pop(context),
        )
      ],
    );
  }
}