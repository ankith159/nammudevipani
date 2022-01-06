import 'package:flutter/material.dart';
import '../shared/Product.dart';
import '../shared/colors.dart';
import '../shared/styles.dart';

Widget foodItem(currency,Product food,
    {double imgWidth, onLike, onTapped, bool isProductPage = false}) {

  return Container(
    width: 180,
    height: 180,
    // color: Colors.red,
    margin: EdgeInsets.only(left: 20),
    child: Stack(
      children: <Widget>[
        Container(
            width: 180,
            height: 160,
            child: RaisedButton(
                color: white,
                elevation: (isProductPage) ? 20 : 12,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                onPressed: onTapped,
                child: Image(image: food.imgUrl !=null ? new NetworkImage(food.imgUrl): AssetImage('assets/steak.png'),
                        width: (imgWidth != null) ? imgWidth : 100,
                        fit: BoxFit.cover,

                ))),

        SizedBox(height: 50),
        Positioned(
          bottom: 0,
          left: 0,
          child: (!isProductPage)
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(food.name, style: foodNameText),
                    Text("$currency"+food.price.toString(), style: priceText),
                  ],
                )
              : Text(' '),
        ),
        SizedBox(height: 50),
      ],
    ),
  );
}
