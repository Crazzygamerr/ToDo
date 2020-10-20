import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  
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
                      ScreenUtil().setHeight(0)),
                  child: Opacity(
                    opacity: 0.65,
                    child: Text(
                      "Registered Email ID",
                      style: TextStyle(fontSize: ScreenUtil().setSp(16)),
                      textAlign: TextAlign.start,
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
                    child: TextFormField(
                      //controller: textCon,
                      keyboardType: TextInputType.emailAddress,
                      textAlign: TextAlign.start,
                      onChanged: (String s) {
                        
                      },
                      onEditingComplete: () {
                      },
                      validator: (value) {
                        
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
                Container(
                  padding:
                      EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(10), 0, 0),
                  alignment: Alignment.bottomCenter,
                  child: RaisedButton(
                    color: Colors.black,
                    child: Text(
                      "Log In",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      //pushOTP();
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(10), 0,
                      ScreenUtil().setHeight(10)),
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
                          //pageCon.jumpToPage(0);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}