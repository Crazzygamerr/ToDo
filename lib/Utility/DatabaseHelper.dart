import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';

class DatabaseHelper {

  static final _databaseName = "Lists";
  static final _databaseVersion = 1;

  static final String table = "Notes";

  static final String columnId = 'id';
  static final String columnTitle = 'title';
  static final String columnContent = 'content';
  static final String columnDate = 'date';
  static final String columnList = 'list';

  static List<String> listOfLists = [
    "Default"
  ];

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
        $columnDate STRING,
        $columnList STRING
      )
    ''');
  }

  Future createTable() async {
    Database db = await instance.database;
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER,
        $columnTitle STRING,
        $columnContent STRING,
        $columnDate STRING,
        $columnList STRING
      )
    ''');
  }
  
  Future<Map<String, dynamic>> add(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = await queryLastId();
    row[columnId] = id + 1;
    await db.insert(table, row);
    return row;
  }

  Future batchInsert(List<Map<String, dynamic>> row) async {
    Database db = await instance.database;
    Batch batch = db.batch();
    for(int i=0;i<row.length;i++)
      batch.insert(table, row[i]);
    await batch.commit();
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
  
  Future drop() async {
    Database db = await instance.database;
    listOfLists = [
      "Default"
    ];
    await db.execute("DROP TABLE $table");
    createTable();
  }

  Future dropList(int index) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnList = ?', whereArgs: [listOfLists[index].toString()]);
  }

  Future insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    await db.insert(table, row);
  }
  
  Future printTable() async {
    var x = await queryAllRows();
    x.forEach((element) {
    });
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
          "title": "Hey there!",
          "content": "",
          "date": null
        }
      ];
  }

  Future queryLastId() async {
    Database db = await instance.database;
    int x = Sqflite.firstIntValue(await db.rawQuery('SELECT * FROM $table ORDER BY  $columnId DESC LIMIT 1'));
    return (x != null)?x:0;
  }

  Future querytables() async {
    Database db = await instance.database;
    var c = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'", null);
    print(c.toString());
  }

  Future<int> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  Future update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  Future getLists() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> x = await db.rawQuery("SELECT `list` FROM $table WHERE $columnContent='3fSX46uKYhH9Z2FuKojZr7CtRV4Lhheb'  ORDER BY  $columnTitle");
    List<String> temp = [];
    temp.add("Default");
    x.forEach((element) {
      temp.add(element['list'].toString());
    });
    listOfLists = temp;
  }

}
