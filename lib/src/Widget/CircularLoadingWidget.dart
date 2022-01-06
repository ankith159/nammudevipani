import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CircularLoadingWidget extends StatefulWidget {
  double height;
  String subtitleText;
  String img;

  CircularLoadingWidget({Key key, this.height,this.subtitleText,this.img }) : super(key: key);

  @override
  _CircularLoadingWidgetState createState() => _CircularLoadingWidgetState();
}

class _CircularLoadingWidgetState extends State<CircularLoadingWidget> with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController animationController;
  bool  loding = false;
  void initState() {
    super.initState();
    animationController = AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    CurvedAnimation curve = CurvedAnimation(parent: animationController, curve: Curves.easeOut);
    animation = Tween<double>(begin: widget.height, end: 0).animate(curve)
      ..addListener(() {
        if (mounted) {
          setState(() {
          });
        }
      });
    Timer(Duration(seconds: 7), () {
      if (mounted) {
        setState(() {
          loding =true;
        });
      }

    });
  }

  @override
  void dispose() {
    animationController.dispose();
    loding =false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: loding == false ?
      SizedBox(
        height: animation.value,
        child: new Center(
          child: new CircularProgressIndicator(),
        ),
      )
          :
      Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        SizedBox(height: 20.0,),
        Center(
          child: Image.asset(
            widget.img,
            height: 200,
            width: 300,
          ),
        ),
        Center(
          child:Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              widget.subtitleText,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 32, vertical: 16.0),
          child: Text(
            'We will ship to anywhere in the world, With 30 day 100% money back policy.',
            textAlign: TextAlign.right,
            style: TextStyle(color: Colors.grey, fontSize: 12.0),
          ),
        ),
      ],
    ),

    );
  }
}
