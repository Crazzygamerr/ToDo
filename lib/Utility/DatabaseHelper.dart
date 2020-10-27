import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';

class DatabaseHelper {

  static final _databaseName = "Lists";
  static final _databaseVersion = 1;

  static final table = "Notes";

  static final columnId = '_id';
  static final columnTitle = 'title';
  static final columnContent = 'content';
  static final columnDate = 'date';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database _database;

  Future<Database> get database async {
    
    //printTable();
    
    if(_database != null)
      return _database;

    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = join(dir.path, _databaseName);

    return await openDatabase(path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER,
        $columnTitle STRING,
        $columnContent STRING,
        $columnDate STRING
      )
    ''');
  }
  
  Future add(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = await queryRowCount();
    row[columnId] = id;
    await db.insert(table, row);
  }

  Future insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    await db.insert(table, row);
  }
  
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> x = await db.query(table);
    if(x != null)
      return List.from(x);
    else
      return [
        {
          "_id": 0,
          "title": "not null test",
          "content": "",
          "date": null
        }
      ];
  }
  
  Future update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }
  
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
  
  Future drop() async {
    Database db = await instance.database;
    await db.execute("DROP TABLE $table");
    _onCreate(db, _databaseVersion);
  }
  
  Future printTable() async {
    var x = await queryAllRows();
    print(x);    
  }

  Future<int> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

}
