import 'package:ToDo/Utility/DatabaseHelper.dart';
import 'package:ToDo/HomeScreen.dart';
import 'package:ToDo/Utility/Shared_pref.dart';
import 'package:ToDo/Widgets/CreateAcc.dart';
import 'package:ToDo/Widgets/LoginScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'todo',
      debugShowCheckedModeBanner: false,
      home: Loading(),
    );
  }
}

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {

  PageController pageCon = new PageController(initialPage: 0);
  bool load = false;

  String s = "Sign Up";

  @override
  void initState() {
    super.initState();
    SharedPref.getUserLogin().then((value) {
      if(value){
        List<Map<String, dynamic>> notes = [];
        final dbHelper = DatabaseHelper.instance;
        dbHelper.getLists();
        dbHelper.querySortedTable().then((value) {
          notes = value;
          Navigator.pushAndRemoveUntil(
                  context,
                  new MaterialPageRoute(
                          builder: (context) => HomeScreen(
                            notes: notes,
                          )
                  ), (route) => false);
        });
      } else {
        setState(() {
          load = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    ScreenUtil.init(context,
        designSize: Size(411.4, 866.3), allowFontScaling: true);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    var bottom = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: ScreenUtil().setHeight(40),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                //padding: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(10), 0, 0),
                child: Image(
                  image: AssetImage("assets/Logo1.png"),
                  height: ScreenUtil().setHeight(150),
                ),
              ),
              Container(
                padding:
                    EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(20), 0, 0),
                child: Text(
                  "todo",
                  style:
                      GoogleFonts.comicNeue(fontSize: ScreenUtil().setSp(75)),
                ),
              ),
            ],
          ),
          SizedBox(
            height: ScreenUtil().setHeight(20),
          ),
          Text(
            "The classic To-Do list",
            style: TextStyle(fontSize: ScreenUtil().setSp(25)),
          ),
          SizedBox(
            height: ScreenUtil().setHeight(20),
          ),

          StatefulBuilder(
            builder: (context, setLoad) {

              if(!load) {
                  return Center(
                    child: Column(
                      children: [
                        SizedBox(
                          height: ScreenUtil().setHeight(125),
                        ),
                        Container(
                          width: ScreenUtil().setWidth(20),
                          height: ScreenUtil().setWidth(20),
                          child: CircularProgressIndicator(),
                        ),
                      ],
                    ),
                  );
              } else {
                return Expanded(
                  child: Container(
                    //color: Colors.green,
                    width: ScreenUtil().setWidth(410),
                    //height: ScreenUtil().setHeight(500),
                    padding: EdgeInsets.only(bottom: bottom),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [

                          SizedBox(
                            height: ScreenUtil().setHeight(
                              (bottom == 0)?50:0
                            ),
                          ),

                          Container(
                            //color: Colors.blue,
                            width: ScreenUtil().setWidth(410),
                            height: ScreenUtil().setHeight(375),
                            child: PageView(
                              controller: pageCon,
                              physics: NeverScrollableScrollPhysics(),
                              children: [
                                LoginScreen(),
                                CreateAcc(),
                              ],
                            ),
                          ),
                          Container(
                            width: ScreenUtil().setWidth(400),
                            height: ScreenUtil().setHeight(1),
                            color: Colors.black.withOpacity(0.1),
                          ),
                          RaisedButton(
                            //color: Color(0xffF8EA6D),
                            color: Colors.white,
                            elevation: 0,
                            /*shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: Colors.black
                              )
                            ),*/
                            child: Container(
                              child: Text(
                                s,
                              ),
                              width: ScreenUtil().setWidth(410),
                              height: ScreenUtil().setHeight(50),
                              alignment: Alignment.center,
                            ),
                            //color: Colors.white,
                            onPressed: () {
                              setState(() {
                                if(pageCon.page == 0){
                                  pageCon.jumpToPage(1);
                                  s = "Log In";
                                } else {
                                  pageCon.jumpToPage(0);
                                  s = "Sign Up";
                                }
                              });
                            },
                          ),

                          Container(
                            width: ScreenUtil().setWidth(400),
                            height: ScreenUtil().setHeight(1),
                            color: Colors.black.withOpacity(0.1),
                          ),

                          RaisedButton(
                            //color: Color(0xffF8EA6D),
                            color: Colors.white,
                            elevation: 0,
                            /*shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: Colors.black
                              )
                            ),*/
                            child: Container(
                              //color: Colors.blue,
                              child: Text("Continue as Guest"),
                              width: ScreenUtil().setWidth(410),
                              height: ScreenUtil().setHeight(50),
                              alignment: Alignment.center,
                            ),
                            //color: Colors.white,
                            onPressed: () {
                               _insert();
                              SharedPref.setUser("guest", true).then((value) {
                                Navigator.pushAndRemoveUntil(
                                        context,
                                        new MaterialPageRoute(
                                                builder: (context) => HomeScreen(notes: [
                                                  {
                                                    DatabaseHelper.columnId: 1,
                                                    DatabaseHelper.columnDone: 0,
                                                    DatabaseHelper.columnTitle: 'Hey there!',
                                                    DatabaseHelper.columnContent  : "",
                                                    DatabaseHelper.columnDate: null,
                                                    DatabaseHelper.columnFullDay: null,
                                                    DatabaseHelper.columnList: "Default"
                                                  }
                                                ],)
                                        ), (route) => false
                                );
                              });
                            },
                          ),

                          Container(
                            width: ScreenUtil().setWidth(400),
                            height: ScreenUtil().setHeight(1),
                            color: Colors.black.withOpacity(0.1),
                          ),

                        ],
                      ),
                    ),
                  ),
                );
              }
            }
          ),
        ],
      ),
    );
  }

  _insert() async {
    final dbHelper = DatabaseHelper.instance;
    Map<String, dynamic> row = {
      DatabaseHelper.columnDone: 0,
      DatabaseHelper.columnTitle: 'Hey there!',
      DatabaseHelper.columnContent: "",
      DatabaseHelper.columnList: "Default"
    };
    await dbHelper.add(row);
  }

}
