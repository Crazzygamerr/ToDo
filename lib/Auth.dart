import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  FirebaseAuth auth = FirebaseAuth.instance;

  Future<bool> emailLogin(String email, String pass) async {
    auth.signInWithEmailAndPassword(email: email, password: pass).then((value) {
      return true;
    }).catchError(() {
      return false;
    });
  }

  Future<bool> createAcc(String email, String pass) async {
    
    auth.createUserWithEmailAndPassword(email: email, password: pass)
        .then((value) {
      
      FirebaseFirestore.instance.collection('Users')
                .doc(email).collection('ToDo Lists')
                .add({
            "title": "Hey there!",
            "content": ""
      });
      return true;
      
    }).catchError((onError) {
      print(onError);
    });
  }
}
