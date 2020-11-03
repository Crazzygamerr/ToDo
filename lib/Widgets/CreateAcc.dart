import 'package:ToDo/Utility/DatabaseHelper.dart';
import 'package:ToDo/HomeScreen.dart';
import 'package:ToDo/Utility/Provider.dart';
import 'package:ToDo/Utility/Shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CreateAcc extends StatefulWidget {
  @override
  _CreateAccState createState() => _CreateAccState();
}

class _CreateAccState extends State<CreateAcc> {
  
  TextEditingController emailCon = new TextEditingController(text: "");
  TextEditingController passCon = new TextEditingController(text: "");
  
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  
  FocusNode node1 = new FocusNode();
  FocusNode node2 = new FocusNode();

  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        width: 411.4, height: 866.3, allowFontScaling: true);

    return Container(
      child: Container(
        child: Column(
          children: [
            Text(
              "Register",
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
                        _formKey1.currentState.validate();
                      } else
                        node2.requestFocus();
                    });
                  },
                  validator: (value) {
                    return "Email id invalid.";
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
                    return "Password is invalid.";
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
                  "Create Account",
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
                    "Already have an account? ",
                    style: TextStyle(fontSize: ScreenUtil().setSp(15)),
                  ),
                  GestureDetector(
                    child: Text(
                      "Log In",
                      style: TextStyle(
                          fontSize: ScreenUtil().setSp(15),
                          fontWeight: FontWeight.w300,
                          decoration: TextDecoration.underline,
                          color: Colors.lightBlue),
                      textAlign: TextAlign.start,
                    ),
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      Provider.of(context).pageCon.jumpToPage(0);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  loginFunc() async {
    FocusNode().unfocus();
    auth.createUserWithEmailAndPassword(
            email: emailCon.text.toString(), password: passCon.text.toString())
        .then((value) {
      _insert();
      FirebaseFirestore.instance.collection("Users").doc(emailCon.text.toString()).set({
        "Create Date": DateTime.now(),
        "lists": ["Default"]
      });
      FirebaseFirestore.instance
          .collection("Users")
          .doc(emailCon.text.toString())
          .collection("todo")
          .add({
        "id": 0,
        "title": "Hey There!",
        "content": "",
        "date": null,
        "list": "Default",
      }).then((value) {
        SharedPref.setUser(emailCon.text.toString(), true);
        Navigator.pushAndRemoveUntil(
                context,
                new MaterialPageRoute(
                        builder: (context) => HomeScreen(notes: [
                          {
                            DatabaseHelper.columnId: 0,
                            DatabaseHelper.columnDone: 0,
                            DatabaseHelper.columnTitle: 'Hey there!',
                            DatabaseHelper.columnContent  : "",
                            DatabaseHelper.columnDate: null,
                            DatabaseHelper.columnList: "Default"
                          }
                        ],)
                ), (route) => false);
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
  
  void _insert() async {
    final dbHelper = DatabaseHelper.instance;
    Map<String, dynamic> row = {
      DatabaseHelper.columnDone: 0,
      DatabaseHelper.columnTitle: 'Hey there!',
      DatabaseHelper.columnContent  : "",
      DatabaseHelper.columnList: "Default"
    };
    await dbHelper.add(row);
  }
  
}
