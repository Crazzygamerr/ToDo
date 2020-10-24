import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  
  static const String login = "login";
  static const String emailKey = "email";

  static Future setUserLogin(String email, bool b) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(emailKey, email);
    pref.setBool(login, b);
  }

  static Future<bool> getUserLogin() async {
    try {
      final SharedPreferences pref = await SharedPreferences.getInstance();
      if (pref.containsKey(login))
        return pref.getBool(login);
      else
        return false;
    } on Exception catch (e) {
      Fluttertoast.showToast(
        msg: "$e",
        textColor: Colors.black,
        fontSize: 20,
        toastLength: Toast.LENGTH_LONG,
      );
      return false;
    }
  }
  
  static Future<String> getEmail() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(emailKey);
  }
  
  
  
}
