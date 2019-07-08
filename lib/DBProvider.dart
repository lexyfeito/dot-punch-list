import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'element.dart';
import 'entry.dart';
import 'model.interface.dart';

class DatabaseHelper<T> {

  // This is the actual database filename that is saved in the docs directory.
  static final _databaseName = "MyPunchListDb.db";
  // Increment this version when you need to change the schema.
  static final _databaseVersion = 1;

  // Make this a singleton class.
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only allow a single open connection to the database.
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  // open the database
  _initDatabase() async {
    // The path_provider plugin gets the right directory for Android or iOS.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    // Open the database. Can also add an onUpdate callback parameter.
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpdate
    );
  }

  Future _onUpdate(db, oldVersion, newVersion) async {

  }

  // SQL string to create the database
  Future _onCreate(Database db, int version) async {
    await db.execute("CREATE TABLE Settings ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "disclaimerClosed INTEGER"
        ")");

    await db.insert('Settings', {"disclaimerClosed": 0});

    await db.execute("CREATE TABLE Projects ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "name TEXT,"
        "description TEXT,"
        "inactive INTEGER"
        ")");

    await db.execute("CREATE TABLE Entries ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "element INTEGER,"
        "location TEXT,"
        "coordinates TEXT,"
        "title TEXT,"
        "comments TEXT,"
        "issue TEXT,"
        "images TEXT,"
        "doneImages Text,"
        "status INTEGER,"
        "time TEXT,"
        "project INTEGER,"
        "remarks TEXT,"
        "providedBy INTEGER"
        ")");

    _createElementsTable(db);
    _createProvidedByTable(db);
  }

  Future query<T extends Model>(String table) async {
    Database db = await database;
    return await db.query(table);
  }

  Future<int> insert<T extends Model>(T entry, String table) async {
    Database db = await database;
    var map = entry.toJson();
    int id = await db.insert(table, map);
    return id;
  }

  Future<int> update<T extends Model>(T entry, String table) async {
    Database db = await database;
    var map = entry.toJson();
    int id = await db.update(table, map, where: "id = ?", whereArgs: [entry.Id]);
    return id;
  }

  Future<int> delete(int id, table) async {
    Database db = await database;
    return await db.delete(table, where: "Id = ?", whereArgs: [id]);
  }

  _createElementsTable(Database db) async {
    await db.execute("CREATE TABLE Elements ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "name TEXT,"
        "description TEXT,"
        "inactive INTEGER"
        ")");
  }

  _createProvidedByTable(Database db) async {
    await db.execute("CREATE TABLE ProvidedBy ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "name TEXT,"
        "inactive INTEGER"
        ")");
  }
}