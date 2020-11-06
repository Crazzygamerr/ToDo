import 'package:ToDo/HomeScreen.dart';
import 'package:ToDo/Utility/DatabaseHelper.dart';
import 'package:ToDo/Utility/Provider.dart';
import 'package:ToDo/Utility/Shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  
  TextEditingController emailCon = new TextEditingController(text: "");
  TextEditingController passCon = new TextEditingController(text: "");

  FocusNode node1 = new FocusNode();
  FocusNode node2 = new FocusNode();

  bool loginBox = false,
          passBox = false,
          loading = false;

  String s = "";

  FirebaseAuth auth = FirebaseAuth.instance;

  final dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    emailCon.text = "test1@test.com";
    passCon.text = "123456";
    super.initState();
  }

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
              "Login",
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
                          onChanged: (value){},
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
                          if (value.exists) {
                            setState(() {
                              loginBox = true;
                            });
                            node2.requestFocus();
                          } else {
                            setState(() {
                              loginBox = false;
                              s = "Email id not found";
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
                      if (!loading) {
                        loginFunc();
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
                "Log In",
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                if (!loading) {
                  loginFunc();
                }
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
    setState(() {
      loading = true;
    });
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
              DatabaseHelper.columnFullDay: (element.data()['fullDay'] != null)?element.data()['fullDay']:null,
              DatabaseHelper.columnList: element.data()['list'],
              //DatabaseHelper.columnPriority: (element.data()['priority'] != null)?element.data()['priority']:null,
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
    setState(() {
      loading  = false;
      s = onError.message;
    });
  });
    loading = false;
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
      if(fireNotes[i]['done'] != null && fireNotes[i]['done'] == 1) {
        doneList.add(fireNotes[i]);
        fireNotes.removeAt(i);
        i--;
      }
    }
    fireNotes.addAll(doneList);
    return fireNotes;
  }

}
