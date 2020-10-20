import 'package:ToDo/HomeScreen.dart';
import 'package:ToDo/Widgets/CreateAcc.dart';
import 'package:ToDo/Widgets/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  PageController pageCon = new PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        width: 411.4, height: 866.3, allowFontScaling: true);

    return Scaffold(
      body: PageView(
        controller: pageCon,
        physics: NeverScrollableScrollPhysics(),
        children: [
        
          CreateAcc(),
        
          LoginScreen(),
          
          Container(
            child: Column(
              children: [
                Text("Are you sure you want to proceed as guest?"),
                Text("Sync will not be available across android devices."),
                Row(
                  children: [
                    RaisedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Back"),
                    ),
                    RaisedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => HomeScreen()),
                            (route) => false);
                      },
                      child: Text("Back"),
                    )
                  ],
                ),
              ],
            ),
          ),
          
        ],
      ),
    );
  }
}
