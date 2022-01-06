import 'package:flutter/material.dart';
import 'package:foodexpress/src/shared/colors.dart';


class StyledFlatButton extends StatelessWidget {
  final String text;
  final onPressed;
  final double radius;

  const StyledFlatButton(this.text, {this.onPressed, Key key, this.radius})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      color: primaryColor,
      splashColor: primaryColor,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16,horizontal: 50),
        child: Text(
          this.text,
          style: TextStyle(fontSize: 20, color: Colors.white, height: 1, fontWeight: FontWeight.w500,),
        ),
      ),
      onPressed: () {
        this.onPressed();
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius ?? 4.0),
        side: BorderSide(
          color: primaryColor,
          width: 4,
        ),
      ),
    );
  }
}