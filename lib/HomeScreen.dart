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
    return FirebaseFirestore.instance
        .collection("Users")
        .doc('Nb4Pc63mVxe65WN5tCxq')
        .collection("ToDo Lists")
        .snapshots();
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
                child: CircularProgressIndicator(),
              ),
            );
          } else {
          
            return Column(
              children: [
              
                GestureDetector(
                  onTap: () {
                    
                  },
                  child: Container(
                    //color: Colors.yellow,
                    height: ScreenUtil().setHeight(50),
                    width: ScreenUtil().setWidth(410),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: ScreenUtil().setWidth(10),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                              0, 0, ScreenUtil().setWidth(12), 0),
                          child: Icon(
                            Icons.add,
                            color: Colors.blue,
                            size: ScreenUtil().setHeight(25),
                          ),
                        ),
                        Text(
                          "Add new item",
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(20),
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                Container(
                  height: ScreenUtil().setHeight(725),
                  //color: Colors.yellow,
                  //width: Screen,
                  child: ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, pos) {
                      return Container(
                        child: Card(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(
                                ScreenUtil().setWidth(20),
                                ScreenUtil().setHeight(20),
                                ScreenUtil().setWidth(20),
                                ScreenUtil().setHeight(20)),
                            child: Row(
                              children: [
                                Text(
                                  snapshot.data.docs[pos].data()['title'],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
