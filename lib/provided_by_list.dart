import 'package:dot_punch_list/project.dart';
import 'package:dot_punch_list/provided.dart';
import 'package:dot_punch_list/provided_by_new_dialog.dart';
import 'package:flutter/material.dart';

class ProvidedByList extends StatefulWidget {

  ProvidedBloc providedByBloc;
  Project project;

  ProvidedByList(this.providedByBloc, this.project);

  @override
  State<StatefulWidget> createState() => _ProvidedByList(providedByBloc, project);
}

class _ProvidedByList extends State<ProvidedByList> {

  ProvidedBloc providedByBloc;
  Project project;

  _ProvidedByList(this.providedByBloc, this.project);

  @override
  void initState() {
    super.initState();
    providedByBloc.providedEventSink.add(GetProvidedEvent(project));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Provided By'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return ProvidedByNewDialog(providedByBloc, project);
              }
          );
        },
      ),
      body: StreamBuilder(
        stream: providedByBloc.provided,
        builder: (context, AsyncSnapshot<List<ProvidedModel>> snapshot) {
          if (snapshot.data == null || snapshot.data.isEmpty) return Center(child: Text('No available provided by', style: TextStyle(color: Colors.grey, fontSize: 22)));
          return ListView.builder(
            itemCount: snapshot.data == null ? 0 : snapshot.data.length,
            itemBuilder: (ctx, index) {
              return ListTile(
                title: Text(snapshot.data[index].Name),
                trailing: IconButton(icon: Icon(Icons.edit), onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return ProvidedByNewDialog(providedByBloc, project, providedBy: snapshot.data[index]);
                    }
                  );
                }),
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Deactivate ${snapshot.data[index].Name}?'),
                        content: Text('Are you sure you want to deactivate this provided by?'),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('Cancel'),
                            onPressed: () => Navigator.pop(context),
                          ),
                          FlatButton(
                            child: Text('Deactivate'),
                            textColor: Colors.red,
                            onPressed: () {
                              snapshot.data[index].Inactive = true;
                              providedByBloc.providedEventSink.add(DeactivateProvidedEvent(snapshot.data[index]));
                              Navigator.pop(context);
                            },
                          )
                        ],
                      );
                    }
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}