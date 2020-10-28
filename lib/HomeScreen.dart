import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';

import 'package:ToDo/Utility/DatabaseHelper.dart';
import 'package:ToDo/Utility/Shared_pref.dart';
import 'package:ToDo/main.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'NoteScreen.dart';

class HomeScreen extends StatefulWidget {

  final List<Map<String, dynamic>> notes;

  @override
  _HomeScreenState createState() => _HomeScreenState();

  HomeScreen({this.notes});
}

class _HomeScreenState extends State<HomeScreen> {

  Stream list;
  String email;
  bool conn = false;
  final dbHelper = DatabaseHelper.instance;
  bool loadSQL = false;
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  FirebaseAuth auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> notes = [];
  int listIndex = 0;

  CollectionReference collectionReference;

  @override
  void initState() {
    getList().then((value) {
      setState(() {
        list = value;
      });
    });
    _connectivitySubscription =  Connectivity().onConnectivityChanged.listen(getInternet);
    super.initState();
    if(widget.notes != null) {
      notes = widget.notes;
      loadSQL = true;
    } else {
      getMap();
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  getList() async {
    email = await SharedPref.getEmail();
    collectionReference = FirebaseFirestore.instance
        .collection("Users")
        .doc(email)
        .collection("todo");
    return collectionReference.orderBy("id").snapshots();
  }

  getInternet(ConnectivityResult result) async {
    bool real;
    await auth.createUserWithEmailAndPassword(email: "test@test.com", password: "testString")
            .catchError((onError){
      if(onError.code == "network-request-failed")
        real = true;
      else
        real = false;
    });
    try {
        var result1 = await InternetAddress.lookup('google.com');
        var result2 = await InternetAddress.lookup('github.com');
        if ((result != ConnectivityResult.none) && !real &&
            (result1.isNotEmpty && result1[0].rawAddress.isNotEmpty ||
            result2.isNotEmpty && result2[0].rawAddress.isNotEmpty)) {
          if(mounted && email != "guest") {
            setState(() {
              conn = true;
            });
          }
          checkSync(await collectionReference.get());
        }
    } on SocketException catch (_) {
        if (mounted) {
          setState(() {
            conn = false;
          });
        }
    }
  }

  getMap() async {
    dbHelper.queryAllRows(listIndex).then((value) {
      setState(() {
        notes = value;
        loadSQL = true;
      });
      if (!(value.length >= 1)) {
        Future.delayed(Duration(seconds: 5)).then((value) {
          if(mounted)
            getMap();
        });
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        width: 411.4, height: 866.3, allowFontScaling: true);

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text((conn)?"firebase":"sqflite"),
        ),
        drawer: Drawer(
          child: Container(
            padding: EdgeInsets.fromLTRB(
                    ScreenUtil().setWidth(10),
                    ScreenUtil().setHeight(25),
                    ScreenUtil().setWidth(10),
                    ScreenUtil().setHeight(10)
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [

                Container(
                  padding: EdgeInsets.fromLTRB(
                          0,
                          0,
                          0,
                          ScreenUtil().setHeight(20)
                  ),
                  child: Icon(
                    Icons.person,
                    size: ScreenUtil().setWidth(75),
                  ),
                ),

                Text(
                  (email == null)
                          ? ""
                          : (email == "guest")
                            ? "Guest"
                            : email,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(30)
                  ),
                ),

                Container(
                  padding: EdgeInsets.fromLTRB(
                          ScreenUtil().setWidth(10),
                          ScreenUtil().setHeight(10),
                          ScreenUtil().setWidth(10),
                          ScreenUtil().setHeight(10)
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Lists:",
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(20)
                    ),
                  ),
                ),

                RaisedButton(
                  child: Text("Add List"),
                  onPressed: () {
                    addList().then((value) {
                      setState(() {
                      });
                    });
                  },
                ),

                Container(
                  padding: EdgeInsets.fromLTRB(
                          ScreenUtil().setWidth(10),
                          ScreenUtil().setHeight(10),
                          ScreenUtil().setWidth(10),
                          ScreenUtil().setHeight(10)
                  ),
                  height: ScreenUtil().setHeight(400),
                  child: ListView.builder(
                    itemCount: DatabaseHelper.listOfTables.length,
                    padding: EdgeInsets.all(0),
                    itemBuilder: (context, pos) {

                      return GestureDetector(
                        onTap: () {
                          listIndex = pos;
                          getMap();
                          Navigator.pop(context);
                        },
                        child: Card(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(
                                    ScreenUtil().setWidth(10),
                                    ScreenUtil().setHeight(10),
                                    ScreenUtil().setWidth(10),
                                    ScreenUtil().setHeight(10)
                            ),
                            child: Row(
                              children: [

                                Text(
                                  DatabaseHelper.listOfTables[pos][0].toString(),
                                  style: TextStyle(
                                    fontSize: ScreenUtil().setSp(15),
                                  ),
                                ),

                                (pos != 0)?IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: Text("Are you sure you want to delete ${DatabaseHelper.listOfTables[pos][0]}?"),
                                        actions: [
                                          FlatButton(
                                            child: Text("No"),
                                            onPressed: (){
                                              Navigator.pop(context);
                                            },
                                          ),
                                          FlatButton(
                                            child: Text("Yes"),
                                            onPressed: (){
                                              Navigator.pop(context);
                                              dbHelper.drop(pos).then((value) {
                                                setState(() {
                                                  listIndex = 0;
                                                });
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      barrierDismissible: false,
                                    );
                                  },
                                  icon: Icon(Icons.delete),
                                ):Container(),

                              ],
                            ),
                          ),
                        ),
                      );

                    },
                  ),
                ),

                RaisedButton(
                  child: Text("Log out"),
                  onPressed: () {
                    dbHelper.dropAllTables();
                    SharedPref.setUserLogin(false);
                    Navigator.pushAndRemoveUntil(context, new MaterialPageRoute(builder: (context) => Loading()), (route) => false);
                  },
                ),

              ],
            ),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: list,
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if(!loadSQL){

              return Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Loading notes..."),
                    Container(
                      width: ScreenUtil().setWidth(20),
                      height: ScreenUtil().setWidth(20),
                      child: CircularProgressIndicator(),
                    ),
                  ],
                ),
              );

            } else if (!snapshot.hasData ||
                snapshot.hasError ||
                snapshot.connectionState == ConnectionState.waiting
                ) {

              return Center(
                child: Container(
                  width: ScreenUtil().setWidth(20),
                  height: ScreenUtil().setWidth(20),
                  child: CircularProgressIndicator(),
                ),
              );

            } else if(snapshot.data.docs.length == 0 && notes.length == 0) {
              return Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [

                    (!conn)?Container(
                      height: ScreenUtil().setHeight(40),
                      width: ScreenUtil().setWidth(411),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(1),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.wifi_off,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: ScreenUtil().setWidth(10),
                          ),
                          Text((email == "guest")?"Log in to sync notes.":"No internet connection",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                    color: Colors.white
                            ),
                          ),
                        ],
                      ),
                    ):Container(),
                    GestureDetector(
                      onTap: () {
                        _insert();
                      },
                      child: Container(
                        //color: Colors.yellow,
                        height: ScreenUtil().setHeight(50),
                        width: ScreenUtil().setWidth(410),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: ScreenUtil().setWidth(10),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, ScreenUtil().setWidth(12), 0),
                              child: Icon(
                                Icons.add,
                                color: Colors.blue,
                                size: ScreenUtil().setHeight(25),
                              ),
                            ),
                            Text(
                              "Add new item",
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(20),
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Expanded(
                      child: Center(
                        child: Text(
                          "No notes here!"
                        ),
                      ),
                    ),

                  ],
                ),
              );
            } else{

              return Column(
                children: [
                  (!conn)?Container(
                    height: ScreenUtil().setHeight(40),
                    width: ScreenUtil().setWidth(411),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(1),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.wifi_off,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: ScreenUtil().setWidth(10),
                        ),
                        Text((email == "guest")?"Log in to sync notes.":"No internet connection",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white
                          ),
                        ),
                      ],
                    ),
                  ):Container(),
                  GestureDetector(
                    onTap: () {
                      _insert(snapshot.data);
                    },
                    child: Container(
                      //color: Colors.yellow,
                      height: ScreenUtil().setHeight(50),
                      width: ScreenUtil().setWidth(410),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: ScreenUtil().setWidth(10),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, ScreenUtil().setWidth(12), 0),
                            child: Icon(
                              Icons.add,
                              color: Colors.blue,
                              size: ScreenUtil().setHeight(25),
                            ),
                          ),
                          Text(
                            "Add new item",
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(20),
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: (conn)?snapshot.data.docs.length:notes.length,
                      itemBuilder: (context, pos) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                new MaterialPageRoute(
                                  builder: (context) => NoteScreen(
                                    snapshot: (conn)?snapshot.data.docs[pos]:null,
                                    note: notes[pos],
                                    index: listIndex,
                                  ),
                                )).then((value) {
                              getMap();
                            });
                          },
                          child: Card(
                            child: Container(
                              padding: EdgeInsets.fromLTRB(
                                  ScreenUtil().setWidth(20),
                                  ScreenUtil().setHeight(10),
                                  ScreenUtil().setWidth(20),
                                  ScreenUtil().setHeight(10)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          (conn)?snapshot.data.docs[pos].data()['title']:notes[pos]['title'],
                                          style: TextStyle(fontSize: 20),
                                        ),
                                        SizedBox(
                                          height: ScreenUtil().setHeight(5),
                                        ),
                                        Text(
                                          (conn)?(
                                            (snapshot.data
                                                    .docs[pos]
                                                    .data()['date'] == null)?
                                              snapshot.data
                                                      .docs[pos]
                                                      .data()['content']:
                                            DateFormat.yMd().add_jm().format(
                                              DateTime.fromMillisecondsSinceEpoch(
                                                      snapshot.data
                                                            .docs[pos]
                                                            .data()['date'].seconds * 1000
                                              )
                                            ).toString()
                                          ):(
                                            (notes[pos]['date'] == null)?
                                              notes[pos]['content']:
                                              DateFormat.yMd().add_jm().format(
                                                      DateTime.parse(
                                                              notes[pos]['date']
                                                      )
                                              ).toString()
                                          ),
                                          maxLines: 2,
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.black.withOpacity(0.65)),
                                              overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      if (conn) {
                                        collectionReference
                                            .doc(snapshot.data.docs[pos].id)
                                            .delete();
                                      }
                                      dbHelper.delete(notes[pos][DatabaseHelper.columnId], listIndex).then((value) {
                                        getMap();
                                      });
                                    },
                                    icon: Icon(Icons.delete),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Future _insert([QuerySnapshot snapshot]) async {
    int p = await dbHelper.queryLastId(listIndex);
    p = p + 1;
    int len = notes.length;
    if (conn) {
      collectionReference.add({
        "id": p,
        "title": "",
        "content": "",
      });
    }
    Map<String, dynamic> row = {
      DatabaseHelper.columnId: p,
      DatabaseHelper.columnTitle: "",
      DatabaseHelper.columnContent: "",
      DatabaseHelper.columnDate: null,
    };
    await dbHelper.add(row, listIndex);
    setState(() {
      notes.insert(len,{
        DatabaseHelper.columnId: p,
        DatabaseHelper.columnTitle: "",
        DatabaseHelper.columnContent: "",
        DatabaseHelper.columnDate: null,
      }
      );
    });
    Navigator.push(
            context,
            new MaterialPageRoute(
              builder: (context) => NoteScreen(
                snapshot: (conn)?snapshot.docs[p]:null,
                note: {
                  DatabaseHelper.columnId: p,
                  DatabaseHelper.columnTitle: "",
                  DatabaseHelper.columnContent: "",
                  DatabaseHelper.columnDate: null,
                },
                index: listIndex,
              ),
            )).then((value) {
      getMap();
    });
  }

  void checkSync(QuerySnapshot snapshot) async {
    if(notes.length >= 1) {
      collectionReference.orderBy("id")
              .get().then((value) {
          for(int i=0;i<value.docs.length;i++)
            if(value.docs[i].data() != notes[value.docs[i].data()['id']]) {
              collectionReference.doc(value.docs[i].id).update({
                "title": notes[i]['title'],
                "content": notes[i]['content'],
                "date": (notes[i]['date'] != null)?Timestamp.fromDate(DateTime.parse(notes[i]['date'])):null
              });
            }
        });
    }
  }

  Future addList() async {
    TextEditingController controller = new TextEditingController();
    String listName;
    final _formKey = GlobalKey<FormState>();

    await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Add a new list"),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            validator: (value) {
              if(controller.text == null || controller.text == "")
                return "List name cannot be empty";
              else
                return null;
            },
          ),
        ),
        actions: [
          FlatButton(
            child: Text("Exit"),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
          FlatButton(
            child: Text("Create"),
            onPressed: (){
              _formKey.currentState.validate();
              if (controller.text != "") {
                listName =  controller.text;
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      barrierDismissible: false,
    );

    if(listName != null && listName != "")
      dbHelper.createTable(listName);
  }

}
