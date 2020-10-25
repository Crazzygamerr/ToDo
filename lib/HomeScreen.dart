import 'dart:async';
import 'dart:io';

import 'package:ToDo/DatabaseHelper.dart';
import 'package:ToDo/Shared_pref.dart';
import 'package:ToDo/main.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'NoteScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
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
    getMap();
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
    return collectionReference.snapshots();
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
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
              title: Text("Internet connection lost."),
              content: Text("Notes will not be synced"),
              actions: [
                  FlatButton(
                      child: Text("Exit"),
                      onPressed: (){
                          Navigator.pop(context);
                      },
                  )
              ],
          ),
          barrierDismissible: false,
      );
    }
  }

  getMap() async {
    dbHelper.queryAllRows().then((value) {
      if (value.length >= 1) {
        setState(() {
          notes = value;
          loadSQL = true;
        });
      } else {
        Future.delayed(Duration(seconds: 5)).then((value) => getMap());
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RaisedButton(
                  child: Text("Log out"),
                  onPressed: () {
                    dbHelper.drop();
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

            } else {

              if(conn) {

                  return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        collectionReference.add({
                          "title": "",
                          "content": "",
                        });
                        _insert("", "");
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
                              padding: EdgeInsets.fromLTRB(
                                  0, 0, ScreenUtil().setWidth(12), 0),
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
                    Container(
                      height: ScreenUtil().setHeight(725),
                      //color: Colors.yellow,
                      //width: Screen,
                      child: ListView.builder(
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (context, pos) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  new MaterialPageRoute(
                                    builder: (context) => NoteScreen(
                                      snapshot: snapshot.data.docs[pos],
                                      note: notes[pos],
                                    ),
                                  ));
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            snapshot.data.docs[pos].data()['title'],
                                            style: TextStyle(fontSize: 20),
                                          ),
                                          Text(
                                            snapshot.data.docs[pos]
                                                .data()['content'],
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
                                        collectionReference
                                            .doc(snapshot.data.docs[pos].id)
                                            .delete();
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

              } else {

                return Column(
                children: [
                  Container(
                    width: ScreenUtil().setWidth(410),
                    height: ScreenUtil().setHeight(20),
                    color: Colors.red,
                  ),
                  GestureDetector(
                    onTap: () {
                      _insert("", "");
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
                            padding: EdgeInsets.fromLTRB(
                                0, 0, ScreenUtil().setWidth(12), 0),
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
                  Container(
                    height: ScreenUtil().setHeight(700),
                    //color: Colors.yellow,
                    //width: Screen,
                    child: ListView.builder(
                      itemCount: notes.length,
                      itemBuilder: (context, pos) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(context, new MaterialPageRoute(
                              builder: (context) => NoteScreen(
                                      note: notes[pos]),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: ScreenUtil().setWidth(310),
                                          child: Text(
                                            notes[pos]['title'],
                                            maxLines: 1,
                                            softWrap: false,
                                            overflow: TextOverflow.fade,
                                            style: TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: ScreenUtil().setWidth(310),
                                          child: Text(
                                            notes[pos]['content'],
                                            maxLines: 2,
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.black.withOpacity(0.65)),
                                                overflow: TextOverflow.fade,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      dbHelper.delete(notes[pos][DatabaseHelper.columnId]).then((value) {
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

            }
          },
        ),
      ),
    );
  }

  Future _insert(String title, String content) async {
    Map<String, dynamic> row = {
      DatabaseHelper.columnTitle: title,
      DatabaseHelper.columnContent: content
    };
    await dbHelper.insert(row).then((value) => getMap());
  }
  
  void checkSync(QuerySnapshot snapshot) async {
    notes = await dbHelper.queryAllRows();
    /*notes.forEach((element) {
      print("sql: " + element['title'] + "\t" + element['content']);
    });
    collectionReference.get().then((ss) {
      ss.docs.forEach((element) { 
        print("firestore: " + element.data()['title'] + "\t" + element.data()['content']);
      });
    });*/
  }
  
}
