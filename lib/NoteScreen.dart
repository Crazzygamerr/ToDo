import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NoteScreen extends StatefulWidget {
  final DocumentSnapshot snapshot;

  NoteScreen({Key key, this.snapshot}) : super(key: key);

  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  TextEditingController titleCon = new TextEditingController();
  TextEditingController contentCon = new TextEditingController();

  @override
  void initState() {
    titleCon.text = widget.snapshot.data()['title'];
    contentCon.text = widget.snapshot.data()['content'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            FocusNode().unfocus();
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: TextFormField(
          maxLines: 1,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Title",
            hintStyle: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      ),
      body: Container(
        child: TextFormField(
          keyboardType: TextInputType.multiline,
          maxLines: null,
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
    );
  }
}
