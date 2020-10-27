import 'package:ToDo/Utility/DatabaseHelper.dart';
import 'package:ToDo/HomeScreen.dart';
import 'package:ToDo/Utility/Provider.dart';
import 'package:ToDo/Utility/Shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
                      .doc(emailCon.text)
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
    //TODO: Change email and pass
    FocusScope.of(context).unfocus();
    auth.signInWithEmailAndPassword(
          email: emailCon.text,
          password: passCon.text)
      .then((value) {
      FirebaseFirestore.instance
              .collection("Users")
              .doc(emailCon.text)
              .collection("todo")
              .orderBy("id")
              .get().then((value) {
        value.docs.forEach((element) {
          String date;
          if(element.data()['date'] != null){
            DateTime d = DateTime.fromMillisecondsSinceEpoch(element.data()['date'].seconds * 1000);
            date = d.toIso8601String();
          }
          _insert(
            element.data()['id'],
            element.data()['title'],
            element.data()['content'],
            date,
          );
        });
      });
      SharedPref.setUser(emailCon.text, true).then((value) {
        Navigator.pushAndRemoveUntil(
                context,
                new MaterialPageRoute(
                        builder: (context) => HomeScreen()
                ), (route) => false);
        });
  }).catchError((onError) {
    _formKey2.currentState.validate();
  });
  }

  Future _insert(int id, String title, String content, String date) async {
    Map<String, dynamic> row = {
      DatabaseHelper.columnId: id,
      DatabaseHelper.columnTitle: title,
      DatabaseHelper.columnContent: content,
      DatabaseHelper.columnDate: date,
    };
    await dbHelper.insert(row);
  }

}
