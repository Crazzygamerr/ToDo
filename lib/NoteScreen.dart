import 'dart:math';

import 'package:ToDo/Utility/DatabaseHelper.dart';
import 'package:ToDo/Utility/Shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class NoteScreen extends StatefulWidget {
  
  final DocumentReference ref;
  final Map<String, dynamic> note;
  final int index;
  final int listIndex;
  final bool create;
  final bool conn;

  NoteScreen({Key key, this.ref, this.note, this.index, this.listIndex, this.create, this.conn}) : super(key: key);

  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  
  TextEditingController titleCon = new TextEditingController();
  TextEditingController contentCon = new TextEditingController();
  
  FocusNode titleNode = new FocusNode();
  FocusNode contentNode = new FocusNode();
  
  final dbHelper = DatabaseHelper.instance;

  String pickedDate;
  TimeOfDay time;

  DocumentSnapshot snapshot;
  Map<String, dynamic> note;
  int index;
  bool create;
  
  @override
  void initState() {
    print("NOTESCREEN....notes............" + widget.note.toString());
    note = widget.note;
    index = widget.index;
    create = widget.create;
    if (!create) {

      titleCon.text = note['title'].toString();
      contentCon.text = (note['content'].toString() == null)?"":note['content'].toString() + "\n\n\n\n\n\n\n\n\n\n";
      pickedDate = note['date'];
      if(pickedDate != null) {
        var temp = DateTime.parse(pickedDate);
        time = new TimeOfDay(hour: temp.hour, minute: temp.minute);
      }
      
    } else {
      _create();
    }
    super.initState();
  }

  Future _create() async {
    contentCon.text = "\n\n\n\n\n\n\n\n\n\n";
    DocumentReference ref;
    note = {
      DatabaseHelper.columnId: index,
      DatabaseHelper.columnTitle: "",
      DatabaseHelper.columnContent: "",
      DatabaseHelper.columnDate: null,
      DatabaseHelper.columnList: DatabaseHelper.listOfLists[widget.listIndex]
    };
    if (widget.conn) {
      ref = await FirebaseFirestore.instance
              .collection("Users")
              .doc(await SharedPref.getEmail())
              .collection("todo").add(note);
      getSnap(ref).then((value) {
        snapshot = value;
      });
    }
    await dbHelper.insert(note);
  }

  Future<DocumentSnapshot> getSnap(DocumentReference ref) async {
    return await ref.get();
  }

  @override
  Widget build(BuildContext context) {

    ScreenUtil.init(context,
            width: 411.4, height: 866.3, allowFontScaling: true);

    return WillPopScope(
      onWillPop: () async {
        await save();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              save();
            },
            icon: Icon(Icons.arrow_back),
          ),
          title: TextFormField(
            keyboardType: TextInputType.text,
            maxLines: 1,
            controller: titleCon,
            focusNode: titleNode,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Title",
              hintStyle: TextStyle(
                color: Colors.grey,
              ),
            ),
            onEditingComplete: () {
              contentNode.requestFocus();
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.fromLTRB(
                    ScreenUtil().setWidth(10),
                    ScreenUtil().setHeight(10),
                    ScreenUtil().setWidth(10),
                    ScreenUtil().setHeight(10)
            ),
            child: Column(
              children: [
                TextFormField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  //minLines: 30,
                  controller: contentCon,
                  focusNode: contentNode,
                  /* style: TextStyle(
                    fontSize: 25,
                  ), */
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),

                Row(
                  children: [
                    Text(
                        (pickedDate != null)?DateFormat.yMd().format(
                        DateTime.parse(
                          pickedDate
                        )
                      ).toString():
                      "Add due date"
                    ),
                    IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () {
                        _selectDate();
                      },
                    ),
                  ],
                ),

                (pickedDate != null)?Row(
                  children: [
                    Text(
                      (time != null)?time.format(context):
                        "No time set"
                    ),
                    IconButton(
                      icon: Icon(Icons.access_time_rounded),
                      onPressed: () {
                        _selectTime();
                      },
                    ),
                  ],
                ):Container(),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Future save() async {
    titleNode.unfocus();
    contentNode.unfocus();
    if(snapshot != null) {
      snapshot.reference
              .update(
                {
                  "title": titleCon.text.toString(),
                  "content": contentCon.text.toString().trim(),
                  "list": DatabaseHelper.listOfLists[widget.listIndex]
                }
              );
    }
    dbHelper.update(
      {
        DatabaseHelper.columnId: note[DatabaseHelper.columnId],
        DatabaseHelper.columnTitle: titleCon.text.toString(),
        DatabaseHelper.columnContent: contentCon.text.toString().trim(),
        DatabaseHelper.columnDate: pickedDate,
        DatabaseHelper.columnList: DatabaseHelper.listOfLists[widget.listIndex],
      },
    ).then((value) {
      Navigator.pop(context);
    });

  }

  _selectDate() async {
    DateTime picked;
    final DateTime d = await showDatePicker(
      context: context,
      initialDate: (pickedDate == null)?DateTime.now():DateTime.parse(pickedDate),
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if(d != null){
      picked = new DateTime(d.year, d.month, d.day);
      if(snapshot != null) {
        snapshot.reference.update({
          DatabaseHelper.columnDate: Timestamp.fromDate(picked)
        });
      }
      setState(() {
        pickedDate = picked.toIso8601String();
      });
    }
  }

  _selectTime() async {
    final TimeOfDay t = await showTimePicker(
      context: context,
      initialTime: (time == null)?TimeOfDay.now():time,
    );
    if(t != null) {
      DateTime temp = DateTime.parse(pickedDate);
      DateTime picked = new DateTime(temp.year, temp.month, temp.day, t.hour, t.minute);
      if(snapshot != null) {
        snapshot.reference.update({
          DatabaseHelper.columnDate: Timestamp.fromDate(picked)
        });
      }
      setState(() {
        time = t;
        pickedDate = picked.toIso8601String();
      });
    }
  }

}
