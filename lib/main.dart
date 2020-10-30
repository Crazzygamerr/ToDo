import 'package:ToDo/Utility/DatabaseHelper.dart';
import 'package:ToDo/HomeScreen.dart';
import 'package:ToDo/Utility/Provider.dart';
import 'package:ToDo/Utility/Shared_pref.dart';
import 'package:ToDo/Widgets/CreateAcc.dart';
import 'package:ToDo/Widgets/LoginScreen.dart';
import 'package:firebase_core/firebase_core.dart';
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

  @override
  void initState() {
    super.initState();
    SharedPref.getUserLogin().then((value) {
      if(value){
        Navigator.pushAndRemoveUntil(
                context,
                new MaterialPageRoute(
                        builder: (context) => HomeScreen()
                ), (route) => false);
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
        width: 411.4, height: 866.3, allowFontScaling: true);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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
            height: 30,
          ),
          Text(
            "The classic To-Do list",
            style: TextStyle(fontSize: 25),
          ),
          SizedBox(
            height: ScreenUtil().setHeight(125),
          ),
          StatefulBuilder(
            builder: (context, setLoad) {

              if(!load) {
                  return Center(
                    child: Container(
                      width: ScreenUtil().setWidth(20),
                      height: ScreenUtil().setWidth(20),
                      child: CircularProgressIndicator(),
                    ),
                  );
              } else {
                return Container(
                  child: Column(
                    children: [
                      Provider(
                        pageCon: pageCon,
                        child: Container(
                          //color: Colors.blue,
                          width: ScreenUtil().setWidth(410),
                          height: ScreenUtil().setHeight(400),
                          child: PageView(
                            controller: pageCon,
                            physics: NeverScrollableScrollPhysics(),
                            children: [
                              LoginScreen(),
                              CreateAcc(),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        child: FlatButton(
                          //color: Color(0xffF8EA6D),
                          child: Container(
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
                                                  DatabaseHelper.columnTitle: 'Hey there!',
                                                  DatabaseHelper.columnContent  : "",
                                                  DatabaseHelper.columnDate: null,
                                                  DatabaseHelper.columnList: "Default"
                                                }
                                              ],)
                                      ), (route) => false
                              );
                            });
                          },
                        ),
                      ),
                    ],
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
      DatabaseHelper.columnTitle: 'Hey there!',
      DatabaseHelper.columnContent  : "",
      DatabaseHelper.columnList: "Default"
    };
    await dbHelper.add(row);
  }

}
