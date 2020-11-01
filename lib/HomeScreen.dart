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

  Stream list1;
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
        list1 = value;
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

  getMap() async {
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
          title: Text(DatabaseHelper.listOfLists[listIndex]),
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
                    /*dbHelper.printTable();
                    notes.forEach((element) {
                      print(element.toString() + "\n");
                    });*/
                    //checkSync();
                    dbHelper.querySortedTable();
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
                          child: Container(
                            padding: EdgeInsets.fromLTRB(
                                    ScreenUtil().setWidth(10),
                                    ScreenUtil().setHeight(10),
                                    ScreenUtil().setWidth(10),
                                    ScreenUtil().setHeight(10)
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [

                                Text(
                                  DatabaseHelper.listOfLists[pos].toString(),
                                  style: TextStyle(
                                    fontSize: ScreenUtil().setSp(15),
                                  ),
                                ),

                                (pos != 0)?IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: Text("Are you sure you want to delete ${DatabaseHelper.listOfLists[pos]}?"),
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
                    dbHelper.drop();
                    SharedPref.setUserLogin(false);
                    Navigator.pushAndRemoveUntil(context, new MaterialPageRoute(builder: (context) => Loading()), (route) => false);
                  },
                ),

              ],
            ),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: list1,
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {

            List<Map<String, dynamic>> fireNotes = [];
            if(snapshot.hasData  && !snapshot.hasError && snapshot.connectionState != ConnectionState.waiting){
              bool hasDate = false;
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

            } else if(fireNotes.length == 0 && notes.length == 0) {
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
                      itemCount: (conn)?(fireNotes.length):notes.length,
                      itemBuilder: (context, pos) {
                        String s1="",s2= "";
                        print(notes[pos]['id'].toString() + "\t" + notes[pos]['title'].toString() + "\t" +notes[pos]['content'].toString() + "\t" +notes[pos]['date'].toString() + "\t" +notes[pos]['done'].toString() + "\t" +notes[pos]['list'].toString() + "\t");
                        print(fireNotes[pos]['id'].toString() + "\t" + fireNotes[pos]['title'].toString() + "\t" +fireNotes[pos]['content'].toString() + "\t" +fireNotes[pos]['date'].toString() + "\t" +fireNotes[pos]['done'].toString() + "\t" +fireNotes[pos]['list'].toString() + "\t" +fireNotes[pos]['ref'].toString() + "\t" );
                        if(notes[pos]['content'].toString() == "3fSX46uKYhH9Z2FuKojZr7CtRV4Lhheb"){
                          return Container();
                        } else if(notes[pos]['list'].toString() != DatabaseHelper.listOfLists[listIndex].toString()) {
                          return Container();
                        } else {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  new MaterialPageRoute(
                                    builder: (context) => NoteScreen(
                                      ref: (conn)?fireNotes[pos]['ref']:null,
                                      note: notes[pos],
                                      index: notes[pos]['id'],
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
                                    ScreenUtil().setWidth(10),
                                    ScreenUtil().setHeight(10),
                                    ScreenUtil().setWidth(20),
                                    ScreenUtil().setHeight(10)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      child: Row(
                                        children: [

                                          Checkbox(
                                            value: (conn)
                                                    ?((fireNotes[pos]['done'] == null)
                                                      ?false
                                                      :(fireNotes[pos]['done'] == 1)?true:false)
                                                    :((notes[pos]['done'] == null)
                                                      ?false
                                                      :(notes[pos]['done'] == 1)?true:false
                                                    ),
                                            onChanged: (b) {
                                              fireNotes[pos]['ref'].update({
                                                "done": (b)?1:0
                                              });
                                              var temp = notes;
                                              temp[pos]['done'] = (b)?1:0;
                                              dbHelper.update(temp[pos]).then((value) {
                                                getMap();
                                              });
                                            },
                                          ),

                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                (conn)?fireNotes[pos]['title'].toString():notes[pos]['title'].toString(),
                                                style: TextStyle(fontSize: 20),
                                              ),
                                              SizedBox(
                                                height: ScreenUtil().setHeight(5),
                                              ),
                                              Text(
                                                (conn)?(
                                                  (fireNotes[pos]['date'] == null)
                                                          ? fireNotes[pos]['content']
                                                          : DateFormat.yMd().add_jm().format(
                                                            DateTime.fromMillisecondsSinceEpoch(
                                                              fireNotes[pos]['date'].seconds * 1000
                                                    )
                                                  ).toString()
                                                ):(
                                                  (notes[pos]['date'] == null)?
                                                    notes[pos]['content'].toString():
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
                index: p,
                listIndex: listIndex,
                create: true,
                conn: conn,
              ),
            )).then((value) {
      getMap();
    });
  }

  void checkSync() async {
    if(notes.length >= 1) {
      collectionReference.orderBy("id")
              .get().then((snapshot) {

          int j=0;

          for(int i=0;i<snapshot.docs.length;i++) {

            if (snapshot.docs[i]['id'] == notes[j]['id']) {
              collectionReference.doc(snapshot.docs[i].id).update({
                "done": notes[j]['done'],
                "title": notes[j]['title'],
                "content": notes[j]['content'],
                "date": (notes[j]['date'] != null)?Timestamp.fromDate(DateTime.parse(notes[j]['date'])):null,
                "list": notes[j]['list']
              });
            } else if(snapshot.docs[i]['id'] > notes[j]['id']) {
              i--;
              j++;
            } else {
              snapshot.docs[i].reference.delete();
            }

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
            keyboardType: TextInputType.text,
            controller: controller,
            autofocus: true,
            validator: (value) {
              if(controller.text == null || controller.text.toString() == "")
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
              if (controller.text.toString() != "") {
                listName =  controller.text.toString();
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      barrierDismissible: false,
    );

    if(listName != null && listName != "") {
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
        getMap();
      }
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
