import 'package:ToDo/HomeScreen.dart';
import 'package:ToDo/NoteScreen.dart';
import 'package:ToDo/Utility/DatabaseHelper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class Search extends SearchDelegate<String> {

  List<Map<String, dynamic>> notes;
  List<Map<String, dynamic>> fireNotes;
  final Function getMap;
  bool conn;

  Search({
    this.notes,
    this.fireNotes,
    this.getMap,
    this.conn
  });

  final dbHelper = DatabaseHelper.instance;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
          onPressed: () {
            query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: (){
        close(context, "");
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if(notes.length == 0) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

            Expanded(
              child: Center(
                child: Text(
                        "No notes found!"
                ),
              ),
            ),

          ],
        ),
      );
    } else {

      //List<bool> firstNote = [true, true, true, true, true, true, true];

      return StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: [

              Expanded(
                child: ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, pos) {

                    /*print(notes[pos]['id'].toString() + "\t" + notes[pos]['title'].toString() + "\t" +notes[pos]['content'].toString() + "\t" +notes[pos]['date'].toString() + "\t" +notes[pos]['done'].toString() + "\t" +notes[pos]['list'].toString() + "\t" + notes[pos]['fullDay'].toString());
                    if(pos<fireNotes.length)
                      print("..........."+fireNotes[pos]['id'].toString() + "\t" + fireNotes[pos]['title'].toString() + "\t" +fireNotes[pos]['content'].toString() + "\t" +fireNotes[pos]['date'].toString() + "\t" +fireNotes[pos]['done'].toString() + "\t" +fireNotes[pos]['list'].toString() + "\t" +fireNotes[pos]['ref'].toString() + "\t" );*/
                    if(notes[pos]['content'].toString() == "3fSX46uKYhH9Z2FuKojZr7CtRV4Lhheb"){
                      return Container();
                    } else if(!(notes[pos]['title'].contains(query) || notes[pos]['content'].contains(query))){
                      return Container();
                    } else {
                      return Column(
                        children: [

                          //dateHead((notes[pos]['date'] != null)?notes[pos]['date']:"", (notes[pos]['done'] != null)?notes[pos]['done']:0, firstNote),

                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                      context,
                                      new MaterialPageRoute(
                                        builder: (context) => NoteScreen(
                                          ref: (conn)?fireNotes[pos]['ref']:null,
                                          note: notes[pos],
                                          id: notes[pos]['id'],
                                          listIndex: notes[pos][DatabaseHelper.columnList],
                                          conn: conn,
                                          create: false,
                                        ),
                                      )).then((value) {
                                getMap();
                              });
                            },
                            child: Card(
                              child: Container(
                                padding: EdgeInsets.fromLTRB(
                                        ScreenUtil().setWidth(0),
                                        ScreenUtil().setHeight(10),
                                        ScreenUtil().setWidth(5),
                                        ScreenUtil().setHeight(10)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      child: Row(
                                        children: [

                                          GestureDetector(
                                            onTap: (){
                                              bool b = (notes[pos]['done'] == null)
                                                      ?false
                                                      :(notes[pos]['done'] == 1)
                                                      ?true
                                                      :false;
                                              b = !b;
                                              if (conn) {
                                                fireNotes[pos]['done'] = (b)?1:0;
                                                fireNotes[pos]['ref'].update({
                                                  "done": (b)?1:0
                                                });
                                              }
                                              var temp = notes;
                                              temp[pos]['done'] =(b)?1:0;
                                              setState((){
                                                notes[pos]['done'] = (b)?1:0;
                                                fireNotes[pos]['done'] = (b)?1:0;
                                              });
                                              dbHelper.update(temp[pos]).then((value) {
                                                getMap();
                                              });
                                            },
                                            child: Container(
                                              //color: Colors.green,
                                              child: Theme(
                                                data: ThemeData(unselectedWidgetColor: Colors.white),
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    Checkbox(
                                                      value: (notes[pos]['done'] == null)
                                                              ?false
                                                              :(notes[pos]['done'] == 1)
                                                              ?true
                                                              :false,
                                                      checkColor: Colors.green,
                                                      activeColor: Colors.white,
                                                      onChanged: (b){
                                                        if (conn) {
                                                          fireNotes[pos]['done'] = (b)?1:0;
                                                          fireNotes[pos]['ref'].update({
                                                            "done": (b)?1:0
                                                          });
                                                        }
                                                        var temp = notes;
                                                        temp[pos]['done'] =(b)?1:0;
                                                        setState((){
                                                          notes[pos]['done'] = (b)?1:0;
                                                          fireNotes[pos]['done'] = (b)?1:0;
                                                        });
                                                        dbHelper.update(temp[pos]).then((value) {
                                                          getMap();
                                                        });
                                                      },
                                                    ),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                              border: Border.all(
                                                                      color: Colors.black,
                                                                      width: 2
                                                              )
                                                      ),
                                                      child: Container(
                                                        height: 18,
                                                        width: 18,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),

                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: ScreenUtil().setWidth(275),
                                                child: Text(
                                                  notes[pos]['title'].toString(),
                                                  style: TextStyle(fontSize: 20),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              SizedBox(
                                                height: ScreenUtil().setHeight(5),
                                              ),
                                              Text(
                                                (notes[pos]['date'] == null)
                                                        ? notes[pos]['content'].toString()
                                                        : (notes[pos]['fullDay'] != null && notes[pos]['fullDay'] != 1)
                                                        ? DateFormat.yMMMMd().add_jm().format(
                                                        DateTime.parse(
                                                                notes[pos]['date']
                                                        )
                                                ).toString()
                                                        : DateFormat.yMMMMd().format(
                                                        DateTime.parse(
                                                                notes[pos]['date']
                                                        )
                                                ).toString(),
                                                maxLines: 2,
                                                style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.black.withOpacity(0.65)
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        if (conn) {
                                          fireNotes[pos]['ref'].delete();
                                        }
                                        dbHelper.delete(notes[pos][DatabaseHelper.columnId]).then((value) {
                                          getMap();
                                        });
                                        setState((){
                                          notes.removeAt(pos);
                                        });
                                      },
                                      icon: Icon(Icons.delete),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
            ],
          );
        }
      );
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if(notes.length == 0) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

            Expanded(
              child: Center(
                child: Text(
                        "No notes found!"
                ),
              ),
            ),

          ],
        ),
      );
    } else {

      //List<bool> firstNote = [true, true, true, true, true, true, true];

      return StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: [

              Expanded(
                child: ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, pos) {
                    //print("------------"+notes[pos]['title'].toString());
                    /*print(notes[pos]['id'].toString() + "\t" + notes[pos]['title'].toString() + "\t" +notes[pos]['content'].toString() + "\t" +notes[pos]['date'].toString() + "\t" +notes[pos]['done'].toString() + "\t" +notes[pos]['list'].toString() + "\t" + notes[pos]['fullDay'].toString());
                    if(pos<fireNotes.length)
                      print("..........."+fireNotes[pos]['id'].toString() + "\t" + fireNotes[pos]['title'].toString() + "\t" +fireNotes[pos]['content'].toString() + "\t" +fireNotes[pos]['date'].toString() + "\t" +fireNotes[pos]['done'].toString() + "\t" +fireNotes[pos]['list'].toString() + "\t" +fireNotes[pos]['ref'].toString() + "\t" );*/
                    if(notes[pos]['content'].toString() == "3fSX46uKYhH9Z2FuKojZr7CtRV4Lhheb"){
                      return Container();
                    } else if(!(notes[pos]['title'].contains(query) || notes[pos]['content'].contains(query))){
                      return Container();
                    }else {
                      return Column(
                        children: [

                          //dateHead((notes[pos]['date'] != null)?notes[pos]['date']:"", (notes[pos]['done'] != null)?notes[pos]['done']:0, firstNote),

                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                      context,
                                      new MaterialPageRoute(
                                        builder: (context) => NoteScreen(
                                          ref: (conn)?fireNotes[pos]['ref']:null,
                                          note: notes[pos],
                                          id: notes[pos]['id'],
                                          listIndex: DatabaseHelper.listOfLists.indexOf(notes[pos][DatabaseHelper.columnList]),
                                          conn: conn,
                                          create: false,
                                        ),
                                      )).then((value) {
                                getMap();
                              });
                            },
                            child: Card(
                              child: Container(
                                padding: EdgeInsets.fromLTRB(
                                        ScreenUtil().setWidth(0),
                                        ScreenUtil().setHeight(10),
                                        ScreenUtil().setWidth(5),
                                        ScreenUtil().setHeight(10)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: (){
                                              bool b = (notes[pos]['done'] == null)
                                                      ?false
                                                      :(notes[pos]['done'] == 1)
                                                      ?true
                                                      :false;
                                              b = !b;
                                              if (conn) {
                                                fireNotes[pos]['done'] = (b)?1:0;
                                                fireNotes[pos]['ref'].update({
                                                  "done": (b)?1:0
                                                });
                                              }
                                              var temp = notes;
                                              temp[pos]['done'] =(b)?1:0;
                                              setState((){
                                                notes[pos]['done'] = (b)?1:0;
                                                fireNotes[pos]['done'] = (b)?1:0;
                                              });
                                              dbHelper.update(temp[pos]).then((value) {
                                                getMap();
                                              });
                                            },
                                            child: Container(
                                              //color: Colors.green,
                                              child: Theme(
                                                data: ThemeData(unselectedWidgetColor: Colors.white),
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    Checkbox(
                                                      value: (notes[pos]['done'] == null)
                                                              ?false
                                                              :(notes[pos]['done'] == 1)
                                                              ?true
                                                              :false,
                                                      checkColor: Colors.green,
                                                      activeColor: Colors.white,
                                                      onChanged: (b){
                                                        if (conn) {
                                                          fireNotes[pos]['done'] = (b)?1:0;
                                                          fireNotes[pos]['ref'].update({
                                                            "done": (b)?1:0
                                                          });
                                                        }
                                                        var temp = notes;
                                                        temp[pos]['done'] =(b)?1:0;
                                                        setState((){
                                                          notes[pos]['done'] = (b)?1:0;
                                                          fireNotes[pos]['done'] = (b)?1:0;
                                                        });
                                                        dbHelper.update(temp[pos]).then((value) {
                                                          getMap();
                                                        });
                                                      },
                                                    ),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                              border: Border.all(
                                                                      color: Colors.black,
                                                                      width: 2
                                                              )
                                                      ),
                                                      child: Container(
                                                        height: 18,
                                                        width: 18,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),

                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: ScreenUtil().setWidth(275),
                                                //color: Colors.blue,
                                                child: Text(
                                                  notes[pos]['title'].toString(),
                                                  style: TextStyle(fontSize: 20),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              SizedBox(
                                                height: ScreenUtil().setHeight(5),
                                              ),
                                              Text(
                                                (notes[pos]['date'] == null)
                                                        ? notes[pos]['content'].toString()
                                                        : (notes[pos]['fullDay'] != null && notes[pos]['fullDay'] != 1)
                                                        ? DateFormat.yMMMMd().add_jm().format(
                                                        DateTime.parse(
                                                                notes[pos]['date']
                                                        )
                                                ).toString()
                                                        : DateFormat.yMMMMd().format(
                                                        DateTime.parse(
                                                                notes[pos]['date']
                                                        )
                                                ).toString(),
                                                maxLines: 2,
                                                style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.black.withOpacity(0.65)
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        if (conn) {
                                          fireNotes[pos]['ref'].delete();
                                        }
                                        dbHelper.delete(notes[pos][DatabaseHelper.columnId]).then((value) {
                                          getMap();
                                        });
                                        setState((){
                                          notes.removeAt(pos);
                                        });
                                      },
                                      icon: Icon(Icons.delete),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
            ],
          );
        }
      );
    }
  }

}
