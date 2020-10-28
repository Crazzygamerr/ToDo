import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';

class DatabaseHelper {

  static final _databaseName = "Lists";
  static final _databaseVersion = 1;

  //static final table = "Notes";

  static final columnId = '_id';
  static final columnTitle = 'title';
  static final columnContent = 'content';
  static final columnDate = 'date';

  static List<List<String>> listOfTables = [
    [
      "Default", "Notes1"
    ]
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
      CREATE TABLE ${listOfTables[0][1]} (
        $columnId INTEGER,
        $columnTitle STRING,
        $columnContent STRING,
        $columnDate STRING
      )
    ''');
  }

  Future createTable(String listName) async {
    Database db = await instance.database;
    int tableNum = int.parse(listOfTables[listOfTables.length-1][1].substring(5));
    tableNum++;
    String tableName = "Notes" + tableNum.toString();
    listOfTables.add([
      listName, tableName
    ]);
    await db.execute('''
      CREATE TABLE $tableName (
        $columnId INTEGER,
        $columnTitle STRING,
        $columnContent STRING,
        $columnDate STRING
      )
    ''');
  }

  Future dropAllTables() async {
    Database db = await instance.database;
    Batch batch = db.batch();
    for(int i=0; i<listOfTables.length;i++) {
      batch.execute("DROP TABLE ${listOfTables[i][1]}");
    }
    listOfTables = [
      [
        "Default", "Notes1"
      ]
    ];
    await batch.commit();
    await _onCreate(db, _databaseVersion);
  }
  
  Future add(Map<String, dynamic> row, int index) async {
    Database db = await instance.database;
    int id = await queryLastId(index);
    row[columnId] = id + 1;
    await db.insert(listOfTables[index][1], row);
  }

  Future insert(Map<String, dynamic> row, int index) async {
    Database db = await instance.database;
    await db.insert(listOfTables[index][1], row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows(int index) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> x = await db.query(listOfTables[index][1]);
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
  
  Future update(Map<String, dynamic> row, int index) async {
    Database db = await instance.database;
    int id = row[columnId];
    await db.update(listOfTables[index][1], row, where: '$columnId = ?', whereArgs: [id]);
  }
  
  Future<int> delete(int id, int index) async {
    Database db = await instance.database;
    return await db.delete(listOfTables[index][1], where: '$columnId = ?', whereArgs: [id]);
  }
  
  Future drop(int index) async {
    Database db = await instance.database;
    await db.execute("DROP TABLE ${listOfTables[index][1]}");
    if(index != 0)
      listOfTables.removeAt(index);
  }
  
  Future printTable(int index) async {
    var x = await queryAllRows(index);
    print(x);    
  }

  Future<int> queryRowCount(int index) async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM ${listOfTables[index][1]}'));
  }

  Future queryLastId(int index) async {
    Database db = await instance.database;
    int x = Sqflite.firstIntValue(await db.rawQuery('SELECT * FROM ${listOfTables[index][1]} ORDER BY  $columnId DESC LIMIT 1'));
    return (x != null)?x:0;
  }

  Future querytables() async {
    Database db = await instance.database;
    var c = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'", null);
    print(c.toString());
  }

}
