import 'dart:math';

import 'package:ToDo/Utility/DatabaseHelper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class NoteScreen extends StatefulWidget {
  
  final DocumentSnapshot snapshot;
  final Map<String, dynamic> note;
  final int index;

  NoteScreen({Key key, this.snapshot, this.note, this.index}) : super(key: key);

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
  
  @override
  void initState() {
    print(widget.note);
    if(widget.snapshot != null) {
      titleCon.text = widget.snapshot.data()['title'];
      contentCon.text = widget.snapshot.data()['content'];
      if(widget.snapshot.data()['date'] != null) {
        DateTime d = DateTime.fromMillisecondsSinceEpoch(
                widget.snapshot.data()['date'].seconds * 1000);
        pickedDate = d.toIso8601String();
      }
    } else {
      titleCon.text = widget.note['title'];
      contentCon.text = widget.note['content'];
      pickedDate = widget.note['date'];
    }
    contentCon.text = contentCon.text + "\n\n\n\n\n\n\n\n\n\n";
    if(pickedDate != null) {
      var temp = DateTime.parse(pickedDate);
      time = new TimeOfDay(hour: temp.hour, minute: temp.minute);
    }
    super.initState();
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
                    hintText: "Content",
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
    if(widget.snapshot != null) {
      widget.snapshot.reference
              .update({"title": titleCon.text, "content": contentCon.text.trim()});
    }
    await dbHelper.update(
      {
        DatabaseHelper.columnId: widget.note[DatabaseHelper.columnId],
        DatabaseHelper.columnTitle: titleCon.text,
        DatabaseHelper.columnContent: contentCon.text.trim(),
        DatabaseHelper.columnDate: pickedDate
      },
      widget.index
    ).then((value) {
      Navigator.pop(context);
    });

  }

  _selectDate() async {
    DateTime picked;
    final DateTime d = await showDatePicker(
      context: context,
      initialDate: (pickedDate == null)?DateTime.now():DateTime.parse(pickedDate),
      firstDate: DateTime(2019),
      lastDate: DateTime(2025),
    );

    if(d != null){
      picked = new DateTime(d.year, d.month, d.day);
      if(widget.snapshot != null) {
        widget.snapshot.reference.update({
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
      if(widget.snapshot != null) {
        widget.snapshot.reference.update({
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
