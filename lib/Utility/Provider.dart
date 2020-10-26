import 'package:flutter/material.dart';

class Provider extends InheritedWidget{

    final Widget child;
    final PageController pageCon;

    Provider({this.child, this.pageCon,});

    @override
    bool updateShouldNotify(InheritedWidget oldWidget) {
        return true;
    }

    static Provider of(BuildContext context){
        return context.dependOnInheritedWidgetOfExactType();
    }

}