import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Stream list;

  @override
  void initState() {
    getList().then((value) {
      setState(() {
        list = value;
      });
    });
    super.initState();
  }

  getList() async {
    return FirebaseFirestore.instance.collection("Users").snapshots();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        width: 411.4, height: 866.3, allowFontScaling: true);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("ToDo List"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: list,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        
          if (!snapshot.hasData ||
              snapshot.hasError ||
              snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Container(
                width: ScreenUtil().setWidth(20),
                height: ScreenUtil().setWidth(20),
                child: CircularProgressIndicator()
              ),
            );
          } else {
            return Text(snapshot.data.docs[0].data()['test']);
          }
        },
      ),
    );
  }
}
