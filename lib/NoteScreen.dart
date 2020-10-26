import 'package:ToDo/Utility/DatabaseHelper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NoteScreen extends StatefulWidget {
  
  final DocumentSnapshot snapshot;
  final Map<String, dynamic> note;

  NoteScreen({Key key, this.snapshot, this.note}) : super(key: key);

  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  
  TextEditingController titleCon = new TextEditingController();
  TextEditingController contentCon = new TextEditingController();
  
  FocusNode titleNode = new FocusNode();
  FocusNode contentNode = new FocusNode();
  
  final dbHelper = DatabaseHelper.instance;
  
  @override
  void initState() {
    
    if(widget.snapshot != null) {
      titleCon.text = widget.snapshot.data()['title'];
      contentCon.text = widget.snapshot.data()['content'];
    } else {
      titleCon.text = widget.note['title'];
      contentCon.text = widget.note['content'];
    }
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await save();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              save();
              Navigator.pop(context);
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
            child: TextFormField(
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
              .update({"title": titleCon.text, "content": contentCon.text});
    }
    await dbHelper.update({
      DatabaseHelper.columnId: widget.note[DatabaseHelper.columnId],
      DatabaseHelper.columnTitle: titleCon.text,
      DatabaseHelper.columnContent: contentCon.text
    });

  }

}
