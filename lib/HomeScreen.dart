import 'dart:async';
import 'dart:io';
import 'package:ToDo/Widgets/Search.dart';
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

  Stream<QuerySnapshot> list1;
  String email;
  bool conn = false, loadSQL = false;
  final dbHelper = DatabaseHelper.instance;
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  FirebaseAuth auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> notes = [];
  List<Map<String, dynamic>> fireNotes = [];
  int listIndex = 0;
  //List<List<int>> noteCount = [];

  CollectionReference collectionReference;

  @override
  void initState() {
    if(widget.notes != null) {
      notes = widget.notes;
      loadSQL = true;
    } else {
      getMap();
    }
    getList().then((value) {
      setState(() {
        list1 = value;
        //load = true;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    if(email != "guest")
      _connectivitySubscription.cancel();
    super.dispose();
  }

  Future getList() async {
    email = await SharedPref.getEmail();
    if (email != "guest") {
      collectionReference = FirebaseFirestore.instance
          .collection("Users")
          .doc(email)
          .collection("todo");
      _connectivitySubscription =  Connectivity().onConnectivityChanged.listen(getInternet);
      return collectionReference.orderBy("id").snapshots();
    }
  }

  /*static getInternetStatic(ConnectivityResult result) async {
    bool real;
    await FirebaseAuth.instance.createUserWithEmailAndPassword(email: "test@test.com", password: "testString")
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
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
  }*/

  getInternet(ConnectivityResult result) async {
    bool real = false;
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
          if(email != "guest")
            checkSync();
        }
    } on SocketException catch (_) {
        if (mounted) {
          setState(() {
            conn = false;
          });
        }
    }
  }

  Future getMap() async {
    dbHelper.getLists();
    dbHelper.querySortedTable().then((value) {
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
    if(mounted && conn) {
      checkSync();
    }
  }

  @override
  Widget build(BuildContext context) {

    ScreenUtil.init(context,
        designSize: Size(411.4, 866.3), allowFontScaling: true);

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          //backgroundColor: Colors.black12,
          title: Text(
            DatabaseHelper.listOfLists[listIndex],
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: (){
                showSearch(context: context, delegate: Search(
                  conn: conn,
                  fireNotes: fireNotes,
                  getMap: getMap,
                  notes: notes
                ));
              },
            ),
          ],
        ),
        drawer: Drawer(
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(
                    ScreenUtil().setWidth(0),
                    ScreenUtil().setHeight(25),
                    ScreenUtil().setWidth(0),
                    ScreenUtil().setHeight(0)
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Container(
                  child: Column(
                    children: [
                      SizedBox(
                        height: ScreenUtil().setHeight(20),
                      ),

                      Text(
                        (email == null)
                                ? ""
                                : (email == "guest")
                                  ? "Guest"
                                  : email,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(20)
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),

                      Container(
                        padding: EdgeInsets.fromLTRB(
                                ScreenUtil().setWidth(10),
                                ScreenUtil().setHeight(10),
                                ScreenUtil().setWidth(10),
                                ScreenUtil().setHeight(5)
                        ),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Lists:",
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(20)
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          addList().then((value) {
                            setState(() {
                            });
                          });
                          //dbHelper.printTable();
                          //print(Timestamp.fromDate(DateTime.parse("2020-11-06T00:00:00.000")).toString() + Timestamp.fromDate(DateTime.parse("2020-11-06T00:00:00.000")).runtimeType.toString());
                          /*notes.forEach((element) {
                            print(element.toString() + "\n");
                          });*/
                          //checkSync();
                          dbHelper.querySortedTable();
                        },
                        child: Container(
                          //color: Colors.yellow,
                          height: ScreenUtil().setHeight(35),
                          //width: ScreenUtil().setWidth(410),
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
                                "Add list",
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
                        padding: EdgeInsets.fromLTRB(
                                ScreenUtil().setWidth(10),
                                ScreenUtil().setHeight(5),
                                ScreenUtil().setWidth(10),
                                ScreenUtil().setHeight(10)
                        ),
                        height: ScreenUtil().setHeight(430),
                        child: ListView.builder(
                          itemCount: DatabaseHelper.listOfLists.length,
                          padding: EdgeInsets.all(0),
                          itemBuilder: (context, pos) {

                            return GestureDetector(
                              onTap: () {
                                listIndex = pos;
                                getMap();
                                Navigator.pop(context);
                              },
                              child: Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                child: Container(
                                  height: ScreenUtil().setHeight(50),
                                  padding: EdgeInsets.fromLTRB(
                                          ScreenUtil().setWidth(10),
                                          ScreenUtil().setHeight(10),
                                          ScreenUtil().setWidth(20),
                                          ScreenUtil().setHeight(10)
                                  ),
                                  decoration: BoxDecoration(
                                    color: (listIndex == pos)?Colors.grey:Colors.white,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  child: Container(
                                    //color: Colors.green,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [

                                        Container(
                                          width: ScreenUtil().setWidth(180),
                                          //color: Colors.blue,
                                          child: Text(
                                            DatabaseHelper.listOfLists[pos].toString(),
                                            style: TextStyle(
                                              fontSize: ScreenUtil().setSp(15),
                                              color: (listIndex != pos)?Colors.black:Colors.white
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),

                                        (pos != 0)?GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                title: Container(
                                                  //width: ScreenUtil().setWidth(400),
                                                  child: Text(
                                                    "Are you sure you want to delete \"${DatabaseHelper.listOfLists[pos]}\"?",
                                                    maxLines: 3,
                                                    style: TextStyle(
                                                            fontSize: ScreenUtil().setSp(17)
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
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
                                                      drop(pos).then((value) {
                                                        listIndex = 0;
                                                        getMap();
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                              barrierDismissible: false,
                                            );
                                          },
                                          child: Container(
                                            //color: Colors.blue,
                                            child: Icon(
                                              Icons.delete,
                                            ),
                                          ),
                                        ):Container(),

                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );

                          },
                        ),
                      ),

                      SizedBox(
                        height: ScreenUtil().setHeight(150),
                      ),
                    ],
                  ),
                ),

                Container(
                  child: Column(
                    children: [
                      Container(
                        color: Colors.black.withOpacity(0.1),
                        height: ScreenUtil().setHeight(1),
                      ),

                      RaisedButton(
                        elevation: 0,
                        color: Colors.white,
                        onPressed: () {
                          DatabaseHelper.listOfLists = [
                            "Default"
                          ];
                          dbHelper.drop();
                          if(email != "guest")
                            auth.signOut();
                          SharedPref.setUserLogin(false);
                          Navigator.pushAndRemoveUntil(context, new MaterialPageRoute(builder: (context) => Loading()), (route) => false);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: ScreenUtil().setWidth(250),
                          height: ScreenUtil().setHeight(40),
                          child: Text(
                            "Log out",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: list1,
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {

            fireNotes = [];
            if(conn && snapshot.hasData  && !snapshot.hasError && snapshot.connectionState != ConnectionState.waiting){
              bool hasDate;
              for(int i=0;i<snapshot.data.docs.length;i++){
                Map<String, dynamic> temp = snapshot.data.docs[i].data();
                temp['ref'] = snapshot.data.docs[i].reference;
                fireNotes.add(temp);
                if(temp['date'] != null)
                  hasDate = true;
              }
              List<Map<String, dynamic>> temp1 = [];
              List<Map<String, dynamic>> temp2 = [];
              if (hasDate) {
                for(int i=0;i<fireNotes.length;i++){
                  if(fireNotes[i]['date'] != null){
                    temp1.add(fireNotes[i]);
                  } else {
                    temp2.add(fireNotes[i]);
                  }
                }
                temp1.sort((a,b) => a['date'].compareTo(b['date']));
                fireNotes = [];
                fireNotes.addAll(temp1);
                fireNotes.addAll(temp2);
                List<Map<String, dynamic>> doneList = [];
                for(int i=0;i<fireNotes.length;i++){
                  if(fireNotes[i]['done'] != null && fireNotes[i]['done'] == 1) {
                    doneList.add(fireNotes[i]);
                    fireNotes.removeAt(i);
                    i--;
                  }
                }
                fireNotes.addAll(doneList);
              }
            }

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

            } else if (conn && !snapshot.hasData ||
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

            } else if(notes.length == 0) {
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
                            overflow: TextOverflow.ellipsis,
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
            } else {

              List<bool> firstNote = [true, true, true, true, true, true, true];

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
                          overflow: TextOverflow.ellipsis,
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
                    child: ListView.builder(
                      itemCount: notes.length,
                      itemBuilder: (context, pos) {

                        print(notes[pos]['id'].toString() + "\t" + notes[pos]['title'].toString() + "\t" +notes[pos]['content'].toString() + "\t" +notes[pos]['date'].toString() + "\t" +notes[pos]['done'].toString() + "\t" +notes[pos]['list'].toString() + "\t" + notes[pos]['fullDay'].toString());
                        if(pos<fireNotes.length)
                          print("..........."+fireNotes[pos]['id'].toString() + "\t" + fireNotes[pos]['title'].toString() + "\t" +fireNotes[pos]['content'].toString() + "\t" +fireNotes[pos]['date'].toString() + "\t" +fireNotes[pos]['done'].toString() + "\t" +fireNotes[pos]['list'].toString() + "\t" +fireNotes[pos]['ref'].toString() + "\t" );
                        if(notes[pos]['content'].toString() == "3fSX46uKYhH9Z2FuKojZr7CtRV4Lhheb"){
                          return Container();
                        } else if(notes[pos]['list'].toString() != DatabaseHelper.listOfLists[listIndex].toString()) {
                          return Container();
                        } else {
                          return Column(
                            children: [

                              dateHead((notes[pos]['date'] != null)?notes[pos]['date']:"", (notes[pos]['done'] != null)?notes[pos]['done']:0, firstNote),

                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      new MaterialPageRoute(
                                        builder: (context) => NoteScreen(
                                          ref: (conn)?fireNotes[pos]['ref']:null,
                                          note: notes[pos],
                                          id: notes[pos]['id'],
                                          listIndex: listIndex,
                                          conn: conn,
                                          create: false,
                                        ),
                                      )).then((value) {
                                    getMap();
                                  });
                                },
                                child: Card(
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(
                                        ScreenUtil().setWidth(0),
                                        ScreenUtil().setHeight(10),
                                        ScreenUtil().setWidth(5),
                                        ScreenUtil().setHeight(10)),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          child: Row(
                                            children: [

                                              GestureDetector(
                                                onTap: (){
                                                  bool b = (notes[pos]['done'] == null)
                                                          ?false
                                                          :(notes[pos]['done'] == 1)
                                                          ?true
                                                          :false;
                                                  b = !b;
                                                  if (conn) {
                                                    fireNotes[pos]['done'] = (b)?1:0;
                                                    fireNotes[pos]['ref'].update({
                                                      "done": (b)?1:0
                                                    });
                                                  }
                                                  var temp = notes;
                                                  temp[pos]['done'] =(b)?1:0;
                                                  dbHelper.update(temp[pos]).then((value) {
                                                    getMap();
                                                  });
                                                },
                                                child: Container(
                                                  //color: Colors.green,
                                                  child: Theme(
                                                    data: ThemeData(unselectedWidgetColor: Colors.white),
                                                    child: Stack(
                                                      alignment: Alignment.center,
                                                      children: [
                                                        Checkbox(
                                                          value: (notes[pos]['done'] == null)
                                                                  ?false
                                                                  :(notes[pos]['done'] == 1)
                                                                  ?true
                                                                  :false,
                                                          checkColor: Colors.green,
                                                          activeColor: Colors.white,
                                                          onChanged: (b){
                                                            if (conn) {
                                                              fireNotes[pos]['done'] = (b)?1:0;
                                                              fireNotes[pos]['ref'].update({
                                                                "done": (b)?1:0
                                                              });
                                                            }
                                                            var temp = notes;
                                                            temp[pos]['done'] =(b)?1:0;
                                                            dbHelper.update(temp[pos]).then((value) {
                                                              getMap();
                                                            });
                                                          },
                                                        ),
                                                        Container(
                                                          decoration: BoxDecoration(
                                                                  border: Border.all(
                                                                          color: Colors.black,
                                                                          width: 2
                                                                  )
                                                          ),
                                                          child: Container(
                                                            height: 18,
                                                            width: 18,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: ScreenUtil().setWidth(275),
                                                    //color: Colors.blue,
                                                    child: Text(
                                                      notes[pos]['title'].toString(),
                                                      style: TextStyle(fontSize: 20),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: ScreenUtil().setHeight(5),
                                                  ),
                                                  Text(
                                                    (notes[pos]['date'] == null)
                                                            ? notes[pos]['content'].toString()
                                                            : (notes[pos]['fullDay'] != null && notes[pos]['fullDay'] != 1)
                                                            ? DateFormat.yMMMMd().add_jm().format(
                                                                DateTime.parse(
                                                                        notes[pos]['date']
                                                                )
                                                              ).toString()
                                                            : DateFormat.yMMMMd().format(
                                                                DateTime.parse(
                                                                        notes[pos]['date']
                                                                )
                                                              ).toString(),
                                                    maxLines: 2,
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.black.withOpacity(0.65)
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            if (conn) {
                                              fireNotes[pos]['ref'].delete();
                                            }
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
                              ),
                            ],
                          );
                        }
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

  Widget dateHead(String dateString, int done, List<bool> firstNote) {

    if(done == 1) {
      if(firstNote[6]) {
        firstNote[6] = false;
        return Container(
          alignment: Alignment.center,
          width: ScreenUtil().setWidth(410),
          height: ScreenUtil().setHeight(30),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.95),
            borderRadius: BorderRadius.circular(10)
          ),
          child: Text(
            "Done",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: ScreenUtil().setSp(17)
            ),
          ),
        );
      } else {
        return Container();
      }
    } else if(dateString == ""){
      if(firstNote[5]) {
        firstNote[5] = false;
        return Container(
          alignment: Alignment.center,
          width: ScreenUtil().setWidth(410),
          height: ScreenUtil().setHeight(30),
          decoration: BoxDecoration(
            //borderRadius: BorderRadius.circular(15),
            //color: Colors.yellow
          ),
          child: Text(
            "No due date",
            style: TextStyle(
              fontSize: ScreenUtil().setSp(17),
            ),
          ),
        );
      } else {
        return Container();
      }
    } else {
      DateTime dateTime = DateTime.parse(dateString);
      int diff = dateTime.difference(DateTime.now()).inDays;
      if(diff < 0){
        if(firstNote[0]) {
          firstNote[0] = false;
          return Container(
            alignment: Alignment.center,
            width: ScreenUtil().setWidth(410),
            height: ScreenUtil().setHeight(30),
            decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10)
            ),
            child: Text("Overdue",
              style: TextStyle(
                color: Colors.white,
                fontSize: ScreenUtil().setSp(17)
              ),
            ),
          );
        } else {
          return Container();
        }
      } else if(diff >= 0 && diff < 7) {
        if(firstNote[1]) {
          firstNote[1] = false;
          return Container(
            alignment: Alignment.center,
            width: ScreenUtil().setWidth(410),
            height: ScreenUtil().setHeight(30),
            decoration: BoxDecoration(
                    //color: Colors.blueAccent.withOpacity(0.8),
                    //borderRadius: BorderRadius.circular(15)
            ),
            child: Text("This week",
              style: TextStyle(
                fontSize: ScreenUtil().setSp(17),
              ),
            ),
          );
        } else {
          return Container();
        }
      } else if(diff >= 7 && diff < 14) {
        if(firstNote[2]) {
          firstNote[2] = false;
          return Container(
            alignment: Alignment.center,
            width: ScreenUtil().setWidth(410),
            height: ScreenUtil().setHeight(30),
            decoration: BoxDecoration(
                    //color: Colors.blueAccent.withOpacity(0.8),
                    //borderRadius: BorderRadius.circular(15)
            ),
            child: Text("Next week",
              style: TextStyle(
                fontSize: ScreenUtil().setSp(17),
              ),
            ),
          );
        } else {
          return Container();
        }
      } else if(diff >= 14 && diff < 30) {
        if(firstNote[3]) {
          firstNote[3] = false;
          return Container(
            alignment: Alignment.center,
            width: ScreenUtil().setWidth(410),
            height: ScreenUtil().setHeight(30),
            decoration: BoxDecoration(
                    //color: Colors.yellow.withOpacity(0.85),
                    //borderRadius: BorderRadius.circular(15)
            ),
            child: Text("This month",
              style: TextStyle(
                fontSize: ScreenUtil().setSp(17),
              ),
            ),
          );
        } else {
          return Container();
        }
      } else {
        if(firstNote[4]) {
          firstNote[4] = false;
          return Container(
            alignment: Alignment.center,
            width: ScreenUtil().setWidth(410),
            height: ScreenUtil().setHeight(30),
            decoration: BoxDecoration(
                    //color: Colors.yellowAccent.withOpacity(0.5),
                    //borderRadius: BorderRadius.circular(15)
            ),
            child: Text("Later",
              style: TextStyle(
                fontSize: ScreenUtil().setSp(17),
              ),
            ),
          );
        } else {
          return Container();
        }
      }
    }

    /*return Container(
      child: Text("test"),
    );*/

  }

  Future _insert() async {
    int p = await dbHelper.queryLastId();
    p = p + 1;
    Map<String, dynamic> row = {
      DatabaseHelper.columnId: p,
      DatabaseHelper.columnTitle: "",
      DatabaseHelper.columnContent: "",
      DatabaseHelper.columnDate: null,
      DatabaseHelper.columnList: DatabaseHelper.listOfLists[listIndex]
    };
    notes.add(row);
    Navigator.push(
            context,
            new MaterialPageRoute(
              builder: (context) => NoteScreen(
                id: p,
                listIndex: listIndex,
                create: true,
                conn: conn,
              ),
            )).then((value) {
      getMap();
    });
  }

  void checkSync() async {
    List<Map<String, dynamic>> sqlNotes = await dbHelper.queryAllRows("id");
    FirebaseFirestore.instance
            .collection("Users")
            .doc(email).get().then((value) {
      value.reference.update({
        "lists": DatabaseHelper.listOfLists
      });
    });
    if(notes.length >= 1) {
      collectionReference.orderBy("id")
              .get().then((snapshot) {
          List<Map<String, dynamic>> cloudNotes = [];
          for(int i=0;i<snapshot.docs.length;i++){
            Map<String, dynamic> temp = snapshot.docs[i].data();
            String date;
            if(temp['date'] != null){
              DateTime d = DateTime.fromMillisecondsSinceEpoch(temp['date'].seconds * 1000);
              date = d.toIso8601String();
            }
            temp['date'] = date;
            bool update = false;
            for(Map element in sqlNotes){
              if(temp['id'] == element['id']){
                update = true;
                break;
              }
            }
            if(update) {
              temp['ref'] = snapshot.docs[i].reference;
              cloudNotes.add(temp);
            } else {
              snapshot.docs[i].reference.delete();
            }
          }

          if (cloudNotes.length == 0) {
            for(int i=0;i<sqlNotes.length;i++){
              Timestamp timestamp;
              if(sqlNotes[i]['date'] != null)
                timestamp = Timestamp.fromDate(DateTime.parse(sqlNotes[i]['date']));
              collectionReference.add({
                "id": sqlNotes[i]['id'],
                "done": sqlNotes[i]['done'],
                "title": sqlNotes[i]['title'],
                "content": sqlNotes[i]['content'],
                "date": timestamp,
                "fullDay": sqlNotes[i]['fullDay'],
                "list": sqlNotes[i]['list']
              });
            }
          } else {
            for(int i=0;i<sqlNotes.length;i++){
              Timestamp timestamp;
              if(sqlNotes[i]['date'] != null)
                timestamp = Timestamp.fromDate(DateTime.parse(sqlNotes[i]['date']));
              bool update = false;
              DocumentReference cloudRef = cloudNotes[0]['ref'];
              for(Map element in cloudNotes){
                if(sqlNotes[i]['id'] == element['id']){
                  update = true;
                  cloudRef = element['ref'];
                  break;
                }
              }
              if(update) {
                cloudRef.update({
                  "done": sqlNotes[i]['done'],
                  "title": sqlNotes[i]['title'],
                  "content": sqlNotes[i]['content'],
                  "date": timestamp,
                  "fullDay": sqlNotes[i]['fullDay'],
                  "list": sqlNotes[i]['list']
                });
              } else {
                collectionReference.add({
                  "id": sqlNotes[i]['id'],
                  "done": sqlNotes[i]['done'],
                  "title": sqlNotes[i]['title'],
                  "content": sqlNotes[i]['content'],
                  "date": timestamp,
                  "fullDay": sqlNotes[i]['fullDay'],
                  "list": sqlNotes[i]['list'],
                });
              }
            }
          }

        });
    }
  }

  Future addList() async {
    TextEditingController controller = new TextEditingController();
    String listName = "";
    final _formKey = GlobalKey<FormState>();

    await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Add a new list"),
        content: Form(
          key: _formKey,
          child: TextFormField(
            keyboardType: TextInputType.text,
            controller: controller,
            autofocus: true,
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
              var state = _formKey.currentState;
              if(state != null)
                state.validate();
              if (controller.text.toString() != "" && !DatabaseHelper.listOfLists.contains(controller.text)) {
                listName =  controller.text.toString();
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      barrierDismissible: false,
    );

    if(listName != "") {
      var temp = await dbHelper.add({
        "title": DatabaseHelper.listOfLists.length.toString(),
        "content": "3fSX46uKYhH9Z2FuKojZr7CtRV4Lhheb",
        DatabaseHelper.columnList: listName.toString()
      });
      DatabaseHelper.listOfLists.add(listName.toString());
      if (conn) {
        FirebaseFirestore.instance
                .collection("Users")
                .doc(email)
                .get().then((value) {
                  value.reference.update({
                    "lists": DatabaseHelper.listOfLists,
                  });
        });
        collectionReference.add(temp);
      }
      getMap();
    }
  }

  Future drop(int pos) async {
    await dbHelper.dropList(pos);
    if (conn) {
      FirebaseFirestore.instance
              .collection("Users")
              .doc(email).get().then((value) {
                var temp = value.data()['lists'];
                temp.removeAt(pos);
                value.reference.update({
                  "lists": temp
                });
      });
      collectionReference.where('list', isEqualTo: DatabaseHelper.listOfLists[pos]).get().then((value) {
        value.docs.forEach((element) {
          element.reference.delete();
        });
      });
    }
    DatabaseHelper.listOfLists.removeAt(pos);
  }
}
