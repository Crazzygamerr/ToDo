import 'package:ToDo/Utility/DatabaseHelper.dart';
import 'package:ToDo/Utility/Shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class NoteScreen extends StatefulWidget {
  
  final DocumentReference ref;
  final Map<String, dynamic> note;
  final int id;
  final int listIndex;
  final bool create;
  final bool conn;

  NoteScreen({this.ref, this.note, this.id = 0, this.listIndex = 0, this.create = false, this.conn = false});

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
  int id, listIndex;
  bool create;
  
  @override
  void initState() {
    print("NOTESCREEN....notes............" + widget.note.toString());
    note = widget.note;
    id = widget.id;
    create = widget.create;
    listIndex = widget.listIndex;
    if (!create) {

      titleCon.text = note['title'].toString();
      contentCon.text = (note['content'].toString() == null)?"":note['content'].toString();
      pickedDate = note['date'];
      if(pickedDate != null && widget.note['fullDay'] != null && widget.note['fullDay'] != 1) {
        var temp = DateTime.parse(pickedDate);
        time = new TimeOfDay(hour: temp.hour, minute: temp.minute);
      }
      
    } else {
      _create();
    }
    super.initState();
  }

  Future _create() async {
    //contentCon.text = "\n\n\n\n\n\n\n\n\n\n";
    DocumentReference ref;
    note = {
      DatabaseHelper.columnId: id,
      DatabaseHelper.columnTitle: "",
      DatabaseHelper.columnContent: "",
      DatabaseHelper.columnDate: null,
      DatabaseHelper.columnList: DatabaseHelper.listOfLists[listIndex]
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
            designSize: Size(411.4, 866.3), allowFontScaling: true);

    return WillPopScope(
      onWillPop: () async {
        await save();
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          //backgroundColor: Colors.black12,
          leading: IconButton(
            onPressed: () {
              save();
            },
            icon: Icon(Icons.arrow_back),
          ),
          title: Text(
            (widget.create)?"Add item":"Edit item"
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            height: ScreenUtil().setHeight(780),
            padding: EdgeInsets.fromLTRB(
                    ScreenUtil().setWidth(10),
                    ScreenUtil().setHeight(10),
                    ScreenUtil().setWidth(10),
                    ScreenUtil().setHeight(10)
            ),
            child: Column(
              children: [

                TextFormField(
                  keyboardType: TextInputType.text,
                  maxLines: 1,
                  controller: titleCon,
                  focusNode: titleNode,
                  autofocus: true,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(22)
                  ),
                  decoration: InputDecoration(
                    labelText: "Title",
                    //border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  onEditingComplete: () {
                    contentNode.requestFocus();
                  },
                ),

                SizedBox(
                  height: ScreenUtil().setHeight(20),
                ),

                Card(
                  child: Container(
                    height: ScreenUtil().setHeight(60),
                    padding: EdgeInsets.fromLTRB(
                            ScreenUtil().setWidth(10),
                            ScreenUtil().setHeight(10),
                            ScreenUtil().setWidth(20),
                            ScreenUtil().setHeight(10)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          //color: Colors.blue,
                          child: Text(
                              (pickedDate != null)?DateFormat.yMMMMd().format(
                              DateTime.parse(
                                pickedDate
                              )
                            ).toString():
                            "Add due date",
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(18),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: ScreenUtil().setWidth(50),
                        ),
                        Container(
                          child: Row(
                            children: [
                              Container(
                                //color: Colors.green,
                                padding: EdgeInsets.fromLTRB(
                                        ScreenUtil().setWidth(0),
                                        ScreenUtil().setHeight(0),
                                        ScreenUtil().setWidth(20),
                                        ScreenUtil().setHeight(0)
                                ),
                                child: GestureDetector(
                                  child: Icon(Icons.calendar_today),
                                  onTap: () {
                                    _selectDate();
                                  },
                                ),
                              ),
                              (pickedDate != null)?GestureDetector(
                                child: Icon(Icons.highlight_remove_outlined),
                                onTap: () {
                                  setState(() {
                                    pickedDate = null;
                                  });
                                },
                              ):Container(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                (pickedDate != null)?Card(
                  child: Container(
                    height: ScreenUtil().setHeight(60),
                    padding: EdgeInsets.fromLTRB(
                            ScreenUtil().setWidth(10),
                            ScreenUtil().setHeight(10),
                            ScreenUtil().setWidth(20),
                            ScreenUtil().setHeight(10)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          (time != null)?time.format(context):
                            "No time set",
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(18),
                            //color: Color(0xffB399D4)
                          ),
                        ),
                        SizedBox(
                          width: ScreenUtil().setWidth(50),
                        ),
                        Container(
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.fromLTRB(
                                        ScreenUtil().setWidth(0),
                                        ScreenUtil().setHeight(0),
                                        ScreenUtil().setWidth(20),
                                        ScreenUtil().setHeight(0)
                                ),
                                child: GestureDetector(
                                  child: Icon(Icons.access_time_rounded),
                                  onTap: () {
                                    _selectTime();
                                  },
                                ),
                              ),
                              (time != null)?GestureDetector(
                                child: Icon(Icons.highlight_remove_outlined),
                                onTap: () {
                                  setState(() {
                                    time = null;
                                    var temp = DateTime.parse(pickedDate);
                                    pickedDate = DateTime(temp.year, temp.month, temp.day, 0, 0).toIso8601String();
                                  });
                                },
                              ):Container(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ):Container(),

                Card(
                  child: Container(
                    height: 60,
                    padding: EdgeInsets.fromLTRB(
                            ScreenUtil().setWidth(10),
                            ScreenUtil().setHeight(10),
                            ScreenUtil().setWidth(10),
                            ScreenUtil().setHeight(10)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Select list",
                          style: TextStyle(
                                  fontSize: ScreenUtil().setSp(18)
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(
                                  ScreenUtil().setWidth(0),
                                  ScreenUtil().setHeight(0),
                                  ScreenUtil().setWidth(10),
                                  ScreenUtil().setHeight(0)
                          ),
                          child: DropdownButton<int>(
                            value: listIndex,
                            icon: Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 16,
                            onChanged: (int newValue) {
                              if(newValue != listIndex){
                                listIndex = newValue;
                              }
                            },
                            items: List.generate(
                                    DatabaseHelper.listOfLists.length,
                                            (index){
                                      return DropdownMenuItem(
                                        value: index,
                                        child: Text("${DatabaseHelper.listOfLists[index]}"),
                                      );
                                    }
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      contentNode.requestFocus();
                    },
                    child: Container(
                      height: ScreenUtil().setHeight(350),
                      child: TextFormField(
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        //minLines: 30,
                        controller: contentCon,
                        focusNode: contentNode,
                        style: TextStyle(
                                fontSize: ScreenUtil().setSp(22)
                        ),
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          labelText: "Description",
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

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
                  "date": (pickedDate != null)?Timestamp.fromDate(DateTime.parse(pickedDate)):null,
                  "fullDay": (time == null)?1:0,
                  "list": DatabaseHelper.listOfLists[listIndex],
                  //"priority":
                }
              );
    }
    dbHelper.update(
      {
        DatabaseHelper.columnId: note[DatabaseHelper.columnId],
        DatabaseHelper.columnTitle: titleCon.text.toString(),
        DatabaseHelper.columnContent: contentCon.text.toString().trim(),
        DatabaseHelper.columnDate: pickedDate,
        DatabaseHelper.columnFullDay: (time == null)?1:0,
        DatabaseHelper.columnList: DatabaseHelper.listOfLists[listIndex],
        //DatabaseHelper.columnPriority:
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
