import 'package:ToDo/Utility/DatabaseHelper.dart';
import 'package:ToDo/HomeScreen.dart';
import 'package:ToDo/Utility/Shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateAcc extends StatefulWidget {
  @override
  _CreateAccState createState() => _CreateAccState();
}

class _CreateAccState extends State<CreateAcc> {
  
  TextEditingController emailCon = new TextEditingController(text: "");
  TextEditingController passCon = new TextEditingController(text: "");
  
  FocusNode node1 = new FocusNode();
  FocusNode node2 = new FocusNode();

  bool loginBox = false,
          passBox = false,
          loading = false;

  String s = "";

  RegExp mailVal = new RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: Size(411.4, 866.3), allowFontScaling: true);

    return Container(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(
                    ScreenUtil().setWidth(15),
                    ScreenUtil().setHeight(0),
                    ScreenUtil().setWidth(0),
                    ScreenUtil().setHeight(0)
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              "Register",
              style: GoogleFonts.comicNeue(fontSize: ScreenUtil().setSp(27)),
              textAlign: TextAlign.start,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                ScreenUtil().setWidth(0),
                ScreenUtil().setHeight(15),
                ScreenUtil().setWidth(10),
                ScreenUtil().setHeight(5)
            ),
            child: Row(
              children: [

                Container(
                  padding: EdgeInsets.fromLTRB(
                          ScreenUtil().setWidth(10),
                          ScreenUtil().setHeight(0),
                          ScreenUtil().setWidth(10),
                          ScreenUtil().setHeight(0)
                  ),
                  child: Theme(
                    data: ThemeData(unselectedWidgetColor: Colors.white),
                    child: Container(
                      decoration: BoxDecoration(
                              border: Border.all(
                                      color: Colors.black,
                                      width: 3
                              )
                      ),
                      child: Container(
                        child: Checkbox(
                          value: loginBox,
                          checkColor: Colors.green,
                          activeColor: Colors.white,
                          onChanged: (value){
                            setState(() {
                              loading=!loading;
                            });
                          },
                        ),
                        width: 15,
                        height: 15,
                      ),
                    ),
                  ),
                ),

                Container(
                  width: ScreenUtil().setWidth(350),
                  height: ScreenUtil().setHeight(47.5),
                  child: TextFormField(
                    controller: emailCon,
                    focusNode: node1,
                    keyboardType: TextInputType.emailAddress,
                    textAlign: TextAlign.start,
                    onChanged: (value) {
                      setState(() {
                        loginBox = false;
                        s = "";
                      });
                    },
                    onEditingComplete: () {
                      if(emailCon.text == "") {
                        setState(() {
                          s = "Email address cannot be empty";
                        });
                      } else {
                        FirebaseFirestore.instance
                                .collection("Users")
                                .doc(emailCon.text.toString())
                                .get()
                                .then((value) {
                          if(!mailVal.hasMatch(emailCon.text)) {
                            setState(() {
                              loginBox = false;
                              s = "Email id is invalid";
                            });
                          } else if (!value.exists) {
                            setState(() {
                              loginBox = true;
                            });
                            node2.requestFocus();
                          } else {
                            setState(() {
                              loginBox = false;
                              s = "Email id already exists!";
                            });
                          }
                        });
                      }
                    },
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                                color: Colors.green
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
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
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              ScreenUtil().setWidth(0),
              ScreenUtil().setHeight(15),
              ScreenUtil().setWidth(10),
              ScreenUtil().setHeight(5),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Stack(
                  children: [
                    Opacity(
                      opacity: (loading)?0:1,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(
                                ScreenUtil().setWidth(10),
                                ScreenUtil().setHeight(12.5),
                                ScreenUtil().setWidth(10),
                                ScreenUtil().setHeight(0)
                        ),
                        child: Theme(
                          data: ThemeData(unselectedWidgetColor: Colors.white),
                          child: Container(
                            decoration: BoxDecoration(
                                    border: Border.all(
                                            color: Colors.black,
                                            width: 3
                                    )
                            ),
                            child: Container(
                              child: Checkbox(
                                value: passBox,
                                checkColor: Colors.green,
                                activeColor: Colors.white,
                                onChanged: (value){},
                              ),
                              width: 15,
                              height: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: (loading)?1:0,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(
                          ScreenUtil().setWidth(10),
                          ScreenUtil().setHeight(15),
                          ScreenUtil().setWidth(7.5),
                          ScreenUtil().setHeight(2.5),
                        ),
                        width: ScreenUtil().setWidth(35),
                        height: ScreenUtil().setHeight(35),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ],
                ),

                Container(
                  width: ScreenUtil().setWidth(350),
                  height: ScreenUtil().setHeight(47.5),
                  child: TextFormField(
                    controller: passCon,
                    focusNode: node2,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    textAlign: TextAlign.start,
                    onChanged: (value){
                      setState(() {
                        passBox = false;
                        s = "";
                      });
                    },
                    onEditingComplete: () {
                      loginFunc();
                    },
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                                color: Colors.green
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
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
              ],
            ),
          ),

          Container(
            padding: EdgeInsets.fromLTRB(
              0,
              ScreenUtil().setHeight(10),
              0,
              ScreenUtil().setHeight(10),
            ),
            //height: ScreenUtil().setHeight(60),
            //color: Colors.blue,
            child: Text(
              s,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),

          Container(
            alignment: Alignment.bottomCenter,
            child: RaisedButton(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                        color: Colors.black,
                        width: 1
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              child: Text(
                "Create Account",
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                loginFunc();
              },
            ),
          ),

        ],
      ),
    );
  }

  loginFunc() async {
    setState(() {
      loading = true;
    });
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
            builder: (context) => HomeScreen(
              notes: [
                {
                  DatabaseHelper.columnId: 0,
                  DatabaseHelper.columnDone: 0,
                  DatabaseHelper.columnTitle: 'Hey there!',
                  DatabaseHelper.columnContent  : "",
                  DatabaseHelper.columnDate: null,
                  DatabaseHelper.columnList: "Default"
                }
              ],
            )
          ),
          (route) => false,
        );
      });
    }).catchError((onError) {
      setState(() {
        loading  = false;
        s = onError.message;
      });
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
