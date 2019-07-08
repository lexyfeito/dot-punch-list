import 'package:flutter/material.dart';

import 'create_edit_element.dart';
import 'element.dart';

class Elements extends StatefulWidget {

  ElementBloc elementBloc;

  Elements(this.elementBloc);

  @override
  State<StatefulWidget> createState() => _Elements(this.elementBloc);
}

class _Elements extends State<Elements> {

  ElementBloc _elementBloc;

  _Elements(this._elementBloc);

  @override
  void initState() {
    super.initState();
    _elementBloc.elementEventSink.add(GetElements());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Categories"),
      ),
      body: StreamBuilder(
        stream: _elementBloc.elements,
        builder: (BuildContext context, AsyncSnapshot<List<ElementModel>> snapshot) {
          return snapshot.data != null && snapshot.data.isNotEmpty ? ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(snapshot.data[index].Name),
                subtitle: snapshot.data[index].Description != null && snapshot.data[index].Description.isNotEmpty ? Text(snapshot.data[index].Description) : null,
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CreateEditElement(snapshot.data[index], _elementBloc))),
                ),
                onLongPress: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Deactivate ${snapshot.data[index].Name}?"),
                          content: Text("Are you sure you want to deactivate this element?"),
                          actions: <Widget>[
                            FlatButton(
                              child: Text("Cancel"),
                              onPressed: () => Navigator.pop(context),
                            ),
                            FlatButton(
                              child: Text("Deactivate"),
                              onPressed: () {
                                _elementBloc.elementEventSink.add(DeactivateElement(snapshot.data[index]));
                                Navigator.pop(context);
                              },
                              textColor: Colors.red,
                            )
                          ],
                        );
                      }
                  );
                },
              );
            },
          ) : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("No available elements", style: TextStyle(
                      color: Colors.grey,
                      fontSize: 22
                  ),)
                ],
              )
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CreateEditElement(null, _elementBloc))),
      ),
    );
  }
}