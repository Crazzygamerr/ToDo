import 'package:ToDo/Utility/DatabaseHelper.dart';
import 'package:ToDo/HomeScreen.dart';
import 'package:ToDo/Utility/Provider.dart';
import 'package:ToDo/Utility/Shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  
  TextEditingController emailCon = new TextEditingController(text: "");
  TextEditingController passCon = new TextEditingController(text: "");
  
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  
  FocusNode node1 = new FocusNode();
  FocusNode node2 = new FocusNode();

  FirebaseAuth auth = FirebaseAuth.instance;

  final dbHelper = DatabaseHelper.instance;

  @override
  Widget build(BuildContext context) {

    ScreenUtil.init(context,
        width: 411.4, height: 866.3, allowFontScaling: true);

    //emailCon.text = "test1@test.com";
    //passCon.text = "123456";

    return Container(
      child: Column(
        children: [
          Text(
            "Login",
            style: TextStyle(fontSize: ScreenUtil().setSp(26)),
            textAlign: TextAlign.start,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                ScreenUtil().setWidth(0),
                ScreenUtil().setHeight(15),
                ScreenUtil().setWidth(0),
                ScreenUtil().setHeight(5)),
            child: Form(
              key: _formKey1,
              child: TextFormField(
                controller: emailCon,
                focusNode: node1,
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.start,
                onEditingComplete: () {
                  FirebaseFirestore.instance
                      .collection("Users")
                      .doc(emailCon.text.toString())
                      .get()
                      .then((value) {
                    if (value.exists) {
                      node2.requestFocus();
                      return null;
                    } else
                      _formKey1.currentState.validate();
                  });
                },
                validator: (value) {
                  return "Email id not found!";
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: EdgeInsets.fromLTRB(
                      ScreenUtil().setWidth(10),
                      ScreenUtil().setHeight(10),
                      ScreenUtil().setWidth(10),
                      ScreenUtil().setHeight(10)),
                  hintText: "Enter your email id",
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                ScreenUtil().setWidth(0),
                ScreenUtil().setHeight(15),
                ScreenUtil().setWidth(0),
                ScreenUtil().setHeight(5)),
            child: Form(
              key: _formKey2,
              child: TextFormField(
                controller: passCon,
                focusNode: node2,
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
                textAlign: TextAlign.start,
                onEditingComplete: () {
                  loginFunc();
                },
                validator: (value) {
                  return "Password is incorrect";
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: EdgeInsets.fromLTRB(
                      ScreenUtil().setWidth(10),
                      ScreenUtil().setHeight(10),
                      ScreenUtil().setWidth(10),
                      ScreenUtil().setHeight(10)),
                  hintText: "Enter your password",
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(10), 0, 0),
            alignment: Alignment.bottomCenter,
            child: RaisedButton(
              color: Colors.black,
              child: Text(
                "Log In",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                loginFunc();
              },
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
                0, ScreenUtil().setHeight(10), 0, ScreenUtil().setHeight(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Don't have an account? ",
                  style: TextStyle(fontSize: ScreenUtil().setSp(15)),
                ),
                GestureDetector(
                  child: Text(
                    "Sign up",
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp(15),
                        fontWeight: FontWeight.w300,
                        decoration: TextDecoration.underline,
                        color: Colors.lightBlue),
                    textAlign: TextAlign.start,
                  ),
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    Provider.of(context).pageCon.jumpToPage(1);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void loginFunc() async {
    FocusScope.of(context).unfocus();
    List<Map<String, dynamic>> notes = [];

    auth.signInWithEmailAndPassword(
          email: emailCon.text.toString(),
          password: passCon.text.toString())
      .then((value) {
      FirebaseFirestore.instance
              .collection("Users")
              .doc(emailCon.text.toString()).get().then((value) {
        DatabaseHelper.listOfLists = [];
        List<dynamic> temp = value.data()['lists'];
        for(var element in temp){
          DatabaseHelper.listOfLists.add(element.toString());
        }
        FirebaseFirestore.instance
                .collection("Users")
                .doc(emailCon.text.toString())
                .collection("todo")
                .orderBy("id")
                .get().then((value) {
          value.docs.forEach((element) {
            String date;
            if(element.data()['date'] != null){
              DateTime d = DateTime.fromMillisecondsSinceEpoch(element.data()['date'].seconds * 1000);
              date = d.toIso8601String();
            }
            Map<String, dynamic> temp = {
              DatabaseHelper.columnId: element.data()['id'],
              DatabaseHelper.columnDone: (element.data()['done'] != null)?element.data()['done']:null,
              DatabaseHelper.columnTitle: element.data()['title'],
              DatabaseHelper.columnContent: element.data()['content'],
              DatabaseHelper.columnDate: date,
              DatabaseHelper.columnList: element.data()['list']
            };
            notes.add(temp);
          });
          notes = sortList(notes);
          _insert(notes);
          SharedPref.setUser(emailCon.text.toString(), true).then((value) {
            Navigator.pushAndRemoveUntil(
                    context,
                    new MaterialPageRoute(
                            builder: (context) => HomeScreen(
                              notes: notes,
                            )
                    ), (route) => false);
          });
        });
      });
  }).catchError((onError) {
      bool b = false;
      FirebaseFirestore.instance
              .collection("Users")
              .doc(emailCon.text.toString())
              .get()
              .then((value) {
        if (!value.exists)
          b = true;
      });

      if(onError.code == "network-request-failed"){
        Fluttertoast.showToast(
          msg: "Network request failed",
          textColor: Colors.black,
          fontSize: 20,
          toastLength: Toast.LENGTH_LONG,
        );
      } else if(b) {
        _formKey1.currentState.validate();
      } else {
        _formKey2.currentState.validate();
      }

  });
  }

  Future _insert(List<Map<String, dynamic>> row) async {
    await dbHelper.batchInsert(row);
  }

  List<Map<String, dynamic>> sortList(List<Map<String, dynamic>> fireNotes) {

    List<Map<String, dynamic>> temp1 = [];
    List<Map<String, dynamic>> temp2 = [];
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
      if(fireNotes[i]['done'] != null && fireNotes[i]['done'] == 1)
        doneList.add(fireNotes[i]);
    }
    for(int i=0;i<fireNotes.length;i++){
      if(fireNotes[i]['done'] != null && fireNotes[i]['done'] == 1)
        fireNotes.removeAt(i);
    }
    fireNotes.addAll(doneList);
    return fireNotes;
  }

}
