import 'package:dot_punch_list/project.dart';
import 'package:dot_punch_list/provided.dart';
import 'package:dot_punch_list/provided_by_list.dart';
import 'package:dot_punch_list/provided_by_new_dialog.dart';
import 'package:flutter/material.dart';
import 'element.dart';
import 'elements.dart';
import 'entry.dart';

class FilterModel {
  bool pendingCheckBox = false;
  bool doneCheckBox = false;
  bool noActionCheckBox = false;

  FilterModel(this.pendingCheckBox, this.doneCheckBox, this.noActionCheckBox);
}

class FilterDrawer extends StatefulWidget {
  Project project;
  EntryBloc _entryBloc;
  ProvidedBloc _providedBlock;
  ElementBloc _elementBloc;
  FilterModel _filterModel;

  FilterDrawer(this.project, this._entryBloc, this._providedBlock, this._elementBloc, this._filterModel) {}

  @override
  State<StatefulWidget> createState() => _FilterDrawer(project, _entryBloc, _providedBlock, _elementBloc, _filterModel);
}

class _FilterDrawer extends State<FilterDrawer> {

  ProvidedBloc _providedBlock;
  ElementBloc _elementBloc;
  FilterModel _filterModel;
  Project project;
  EntryBloc _entryBloc;

  _FilterDrawer(this.project, this._entryBloc, this._providedBlock, this._elementBloc, this._filterModel) {}

  @override
  void initState() {
    super.initState();
    _providedBlock.providedEventSink.add(null);
    _elementBloc.elementEventSink.add(null);
  }

  void _filterEntries() async {
    String query = "";
    String providedByQuery = "";
    String elementQuery = "";
    String statusQuery = "";
    _providedBlock.providedList.forEach((provided) {
      if (provided.Selected == true) {
        var index = provided.Id;
        providedByQuery += providedByQuery.isEmpty ? "Entries.providedBy = $index" : " OR Entries.providedBy = $index";
      }
    });

    _elementBloc.elementsList.forEach((element) {
      if (element.Selected == true) {
        var index = element.Id;
        elementQuery += elementQuery.isEmpty ? "Entries.element = $index" : " OR Entries.element = $index";
      }
    });

    if (_filterModel.pendingCheckBox == true) statusQuery += statusQuery.isEmpty ? "Entries.status = 0" : " OR Entries.status = 0";
    if (_filterModel.doneCheckBox == true) statusQuery += statusQuery.isEmpty ? "Entries.status = 1" : " OR Entries.status = 1";
    if (_filterModel.noActionCheckBox == true) statusQuery += statusQuery.isEmpty ? "Entries.status = 2" : " OR Entries.status = 2";

//    if (_selectedProvidedBy != null) {
//      if (query.isNotEmpty) query += " OR ";
//      // query += "Entries.providedBy LIKE '%${_providedByController.text}%'";
//      query += "Entries.providedBy = $_selectedProvidedBy";
//    }

    if (providedByQuery.isNotEmpty && (elementQuery.isNotEmpty || statusQuery.isNotEmpty))
      query += "($providedByQuery) AND ";
    else query = providedByQuery;

    if (elementQuery.isNotEmpty && statusQuery.isNotEmpty)
      query += "($elementQuery) AND ";
    else query += elementQuery;

    query += statusQuery;

    _entryBloc.entryEventSink.add(GetEntries(project, query: query));
  }

  @override
  void dispose() {
    super.dispose();
    // _providedBlock.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                  child: Text("Provided by", style: TextStyle(fontSize: 18),),
                ),
                Divider(),
                StreamBuilder(
                  stream: _providedBlock.provided,
                  builder: (BuildContext context, AsyncSnapshot<List<ProvidedModel>> snapshot) {
                    if (snapshot.data == null) return Text('');
                    return Column(
                      children: snapshot.data.where((i) => i.Selected).map((i) => ListTile(
                        title: Text(i.Name), trailing: GestureDetector(child: Icon(Icons.delete, color: Colors.red,), onTap: () {
                          i.Selected = !i.Selected;
                          _providedBlock.providedEventSink.add(EditProvidedEvent(i));
                      },),)).toList(),
                    );
                  },
                ),
                Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
//                  child: TextField(
//                    decoration: InputDecoration(
//                        labelText: "Provide By"
//                    ),
//                    controller: _providedByController,
//                  ),
//                  child: StreamBuilder(
//                    stream: _providedBlock.provided,
//                    builder: (BuildContext context, AsyncSnapshot<List<ProvidedModel>> snapshot) {
//                      return DropdownButtonFormField(
//                        value: _selectedProvidedBy,
//                        hint: Text("Provided By"),
//                        items: snapshot.data != null ? snapshot.data.map((i) {
//                          return DropdownMenuItem(
//                            value: i.Id,
//                            child: Text(i.Name.toString()),
//                          );
//                        }).toList() : [],
//                        onChanged: (value) => setState(() => _selectedProvidedBy = value),
//                      );
//                    },
//                  ),
                  child: FlatButton(
                    child: Text('Select'),
                    textTheme: ButtonTextTheme.accent,
                    onPressed: () => _showProvidedByDialog(context),
                  ),
                ),
                Divider(),
                Container(
                  margin: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                  child: Text("Category", style: TextStyle(fontSize: 18),),
                ),
                Divider(),
                StreamBuilder(
                  stream: _elementBloc.elements,
                  builder: (BuildContext context, AsyncSnapshot<List<ElementModel>> snapshot) {
                    if (snapshot.data == null) return Text('');
                    return Column(
                      children: snapshot.data.where((i) => i.Selected).map((i) => ListTile(
                        title: Text(i.Name), trailing: GestureDetector(child: Icon(Icons.delete, color: Colors.red,), onTap: () {
                        i.Selected = !i.Selected;
                        _elementBloc.elementEventSink.add(EditElement(i));
                      },),)).toList(),
                    );
                  },
                ),
                Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  child: FlatButton(
                    child: Text("Select"),
                    textTheme: ButtonTextTheme.accent,
                    onPressed: () {
                      _showElementsDialog(context);
                    },
                  ),
                ),
                Divider(),
                Container(
                  margin: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                  child: Text("Status", style: TextStyle(fontSize: 18),),
                ),
                Divider(),
                Column(
                  children: <Widget>[
                    ListTile(
                      title: Text('Pending'),
                      trailing: Checkbox(
                        value: _filterModel.pendingCheckBox,
                      ),
                      onTap: () {
                        // Navigator.pop(context);
                        setState(() => _filterModel.pendingCheckBox = !_filterModel.pendingCheckBox);
                      },
                    ),
                    ListTile(
                      title: Text('Done'),
                      trailing: Checkbox(
                        value: _filterModel.doneCheckBox,
                      ),
                      onTap: () {
                        // Navigator.pop(context);
                        setState(() => _filterModel.doneCheckBox = !_filterModel.doneCheckBox);
                      },
                    ),
                    ListTile(
                      title: Text('No Action'),
                      trailing: Checkbox(
                        value: _filterModel.noActionCheckBox,
                      ),
                      onTap: () {
                        // Navigator.pop(context);
                        setState(() => _filterModel.noActionCheckBox = !_filterModel.noActionCheckBox);
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 10, right: 10),
                child: FlatButton(
                  textTheme: ButtonTextTheme.accent,
                  child: Text("Search / Clear filters"),
                  onPressed: _filterEntries,
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  _showProvidedByDialog(context) async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Container(
              width: 300,
              child: ProvidedByDialog(_providedBlock),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Close"),
                onPressed: () => Navigator.pop(context),
              ),
              IconButton(
                icon: Icon(Icons.settings),
                color: Colors.blue,
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProvidedByList(_providedBlock, project))),
              )
            ],
          );
        }
    );

    // Future.delayed(const Duration(milliseconds: 100), () => _providedBlock.providedEventSink.add(GetProvidedEvent()));
  }

  _showElementsDialog(context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Container(
            width: 300,
            child: ElementsDialog(_elementBloc),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Close"),
              onPressed: () => Navigator.pop(context),
            ),
            IconButton(
              icon: Icon(Icons.settings),
              color: Colors.blue,
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Elements(_elementBloc))),
            )
          ],
        );
      }
    );
  }
}

class ProvidedByDialog extends StatefulWidget {
  ProvidedBloc _providedBloc;
  ProvidedByDialog(this._providedBloc);

  @override
  State<StatefulWidget> createState() => _ProvidedByDialogState(_providedBloc);
}

class _ProvidedByDialogState extends State<ProvidedByDialog> {
  ProvidedBloc _providedBloc;
  _ProvidedByDialogState(this._providedBloc);

  @override
  Widget build(BuildContext context) {
    if (_providedBloc.providedList.isEmpty) return Text("No available provided by.");
    return ListView.builder(
      itemCount: _providedBloc.providedList.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(_providedBloc.providedList[index].Name),
          trailing: Checkbox(value: _providedBloc.providedList[index].Selected),
          onTap: () {
            setState(() => _providedBloc.providedList[index].Selected = !_providedBloc.providedList[index].Selected);
            _providedBloc.providedEventSink.add(EditProvidedEvent(_providedBloc.providedList[index]));
          },
        );
      },
    );
  }
}

class ElementsDialog extends StatefulWidget {
  ElementBloc _elementBloc;
  ElementsDialog(this._elementBloc);

  @override
  State<StatefulWidget> createState() => _ElementsDialogState(_elementBloc);
}

class _ElementsDialogState extends State<ElementsDialog> {
  ElementBloc _elementBloc;
  _ElementsDialogState(this._elementBloc);

  @override
  Widget build(BuildContext context) {
    if (_elementBloc.elementsList.isEmpty) return Text("No available category.");
    return ListView.builder(
      itemCount: _elementBloc.elementsList.length,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, index) {
        return ListTile(
          title: Text(_elementBloc.elementsList[index].Name),
          trailing: Checkbox(value: _elementBloc.elementsList[index].Selected),
          onTap: () {
            setState(() => _elementBloc.elementsList[index].Selected = !_elementBloc.elementsList[index].Selected);
            _elementBloc.elementEventSink.add(EditElement(_elementBloc.elementsList[index]));
          },
        );
      },
    );
  }
}