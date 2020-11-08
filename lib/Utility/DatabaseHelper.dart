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
  static final String columnDone = 'done';
  static final String columnList = 'list';
  static final String columnFullDay = 'fullDay';
  //static final String columnPriority = 'priority';

  static List<String> listOfLists = [
    "Default"
  ];

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static late Database _database;

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
        $columnDone INTEGER,
        $columnTitle STRING,
        $columnContent STRING,
        $columnDate STRING,
        $columnFullDay INTEGER,
        $columnList STRING
      )
    ''');
  }

  Future createTable() async {
    Database db = await instance.database;
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER,
        $columnDone INTEGER,
        $columnTitle STRING,
        $columnContent STRING,
        $columnDate STRING,
        $columnFullDay INTEGER,
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

  Future insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    await db.insert(table, row);
  }
  
  Future printTable() async {
    var x = await queryAllRows(columnId);
    x.forEach((element) {
      print("-----------" + element.toString() + "\n");
    });
  }

  Future<List<Map<String, dynamic>>> queryAllRows(String orderBy, {bool desc = false}) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> x;
    if(desc)
      x = await db.rawQuery('SELECT * FROM $table ORDER BY  $orderBy DESC');
    else
      x = await db.rawQuery('SELECT * FROM $table ORDER BY  $orderBy');

    List<Map<String, dynamic>> temp = [];
    x.forEach((element) {
      temp.add({
        columnId: element[columnId],
        columnTitle: element[columnTitle],
        columnContent: element[columnContent],
        columnDone: element[columnDone],
        columnFullDay: element[columnFullDay],
        columnDate: element[columnDate],
        columnList: element[columnList],
        //columnPriority: element[columnPriority]
      });
    });
    return temp;
  }

  Future queryLastId() async {
    Database db = await instance.database;
    int x = Sqflite.firstIntValue(await db.rawQuery('SELECT * FROM $table ORDER BY  $columnId DESC LIMIT 1'));
    return (x != null)?x:0;
  }

  Future querytables() async {
    Database db = await instance.database;
    var c = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
    return c;
  }

  Future<List<Map<String, dynamic>>> querySortedTable() async {
    Database db = await instance.database;

    List<Map<String, dynamic>> nullList = await db.rawQuery("SELECT * FROM $table WHERE $columnDate IS NULL ORDER BY $columnId");
    List<Map<String, dynamic>> notNullList = await db.rawQuery("SELECT * FROM $table WHERE $columnDate IS NOT NULL ORDER BY $columnDate");
    List<Map<String, dynamic>> list = [];
    notNullList.forEach((element) {
      list.add({
        columnId: element[columnId],
        columnTitle: element[columnTitle],
        columnContent: element[columnContent],
        columnDone: element[columnDone],
        columnDate: element[columnDate],
        columnFullDay: element[columnFullDay],
        columnList: element[columnList],
        //columnPriority: element[columnPriority]
      });
    });
    nullList.forEach((element) {
      list.add({
        columnId: element[columnId],
        columnTitle: element[columnTitle],
        columnContent: element[columnContent],
        columnDone: element[columnDone],
        columnDate: element[columnDate],
        columnFullDay: element[columnFullDay],
        columnList: element[columnList],
        //columnPriority: element[columnPriority]
      });
    });
    List<Map<String, dynamic>> doneList = [];
    for(int i=0;i<list.length;i++){
      if(list[i]['done'] != null && list[i]['done'] == 1) {
        doneList.add(list[i]);
        list.removeAt(i);
        i--;
      }
    }
    list.addAll(doneList);
    print(list);
    return list;
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

}
