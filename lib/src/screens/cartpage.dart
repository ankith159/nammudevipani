import 'dart:ffi';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodexpress/config/api.dart';
import 'package:foodexpress/providers/auth.dart';
import 'package:foodexpress/src/Widget/CircularLoadingWidget.dart';
import 'package:foodexpress/src/screens/CheckOutPage.dart';
import 'package:foodexpress/src/screens/loginPage.dart';
import 'package:foodexpress/src/shared/colors.dart';
import 'package:foodexpress/src/utils/CustomTextStyle.dart';
import 'package:foodexpress/src/utils/CustomUtils.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:foodexpress/models/cartmodel.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CartPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CartPageState();
  }
}

class _CartPageState extends State<CartPage> {
  String api = FoodApi.baseApi;

  initAuthProvider(context) async {
    Provider.of<AuthProvider>(context, listen: false).initAuthProvider();
  }

  Future<Void> deviceTokenUpdate(token) async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    var deviceToken = storage.getString('deviceToken');
    final url = "$api/device?device_token=$deviceToken";
    final response = await http.put(Uri.parse(url), headers: {
      HttpHeaders.acceptHeader: "application/json",
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });
  }

  Future<void> _showAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Product Stock Out'),
          actions: <Widget>[
            FlatButton(
              child: Text('Dismiss'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    initAuthProvider(context);
  }

  @override
  Widget build(BuildContext context) {
    final token = Provider.of<AuthProvider>(context).token;
    final currency = Provider.of<AuthProvider>(context).currency;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text("Cart"),
        actions: <Widget>[
          FlatButton(
              child: Text(
                "Clear",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () => ScopedModel.of<CartModel>(context).clearCart())
        ],
      ),
      body: ScopedModel.of<CartModel>(context, rebuildOnChange: true)
                  .cart
                  .length ==
              0
          ? CircularLoadingWidget(
              height: 200,
              subtitleText: 'No items in Cart',
              img: 'assets/shopping1.png',
            )
          : Container(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                      itemCount: ScopedModel.of<CartModel>(context,
                              rebuildOnChange: true)
                          .total,
                      itemBuilder: (context, index) {
                        return ScopedModelDescendant<CartModel>(
                          builder: (context, child, model) {
                            return createCartListItem(currency, model, index);
                          },
                        );
                      },
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Total: $currency " +
                            ScopedModel.of<CartModel>(context,
                                    rebuildOnChange: true)
                                .totalCartValue
                                .toString() +
                            "",
                        style: TextStyle(
                            fontSize: 24.0, fontWeight: FontWeight.bold),
                      )),
                  SizedBox(
                    width: double.infinity,
                    child: RaisedButton(
                      color: primaryColor,
                      textColor: Colors.white,
                      elevation: 0,
                      child: Text("BUY NOW"),
                      onPressed: () async {
                        // ignore: unrelated_type_equality_checks
                        deviceTokenUpdate(token);

                        if (token != null) {
                          if (ScopedModel.of<CartModel>(context,
                                      rebuildOnChange: true)
                                  .totalCartValue <
                              300.00) {
                            Fluttertoast.showToast(msg: 'Min value is Rs 300');
                          } else
                            Navigator.push(
                              context,
                              new MaterialPageRoute(
                                builder: (context) => CheckOutPage(),
                              ),
                            );
                        } else {
                          Navigator.push(
                            context,
                            new MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  createCartListItem(currency, CartModel model, index) {
    return Stack(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(left: 16, right: 16, top: 16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(16))),
          child: Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 8, left: 8, top: 8, bottom: 8),
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                    color: primaryColor.withOpacity(0.7),
                    image: DecorationImage(
                        image: NetworkImage(model.cart[index].imgUrl))),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(right: 8, top: 4),
                        child: Text(
                          model.cart[index].name,
                          maxLines: 2,
                          softWrap: true,
                          style: CustomTextStyle.textFormFieldSemiBold
                              .copyWith(fontSize: 14),
                        ),
                      ),
                      Utils.getSizedBox(height: 6),
                      Text(
                        model.cart[index].qty.toString() +
                            " x " +
                            model.cart[index].price.toString() +
                            " = " +
                            (model.cart[index].qty * model.cart[index].price)
                                .toString(),
                        style: CustomTextStyle.textFormFieldRegular
                            .copyWith(color: Colors.grey, fontSize: 14),
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              "$currency" +
                                  (model.cart[index].qty *
                                          model.cart[index].price)
                                      .toString(),
                              style: CustomTextStyle.textFormFieldBlack
                                  .copyWith(color: primaryColor),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(
                                      Icons.remove,
                                      size: 24,
                                    ),
                                    onPressed: () {
                                      model.updateProduct(
                                          model.cart[index].id,
                                          model.cart[index].price,
                                          model.cart[index].qty - 1);
                                      // model.removeProduct(model.cart[index]);
                                    },
                                  ),
                                  Container(
                                    color: Colors.grey.shade200,
                                    padding: const EdgeInsets.only(
                                        bottom: 12,
                                        right: 12,
                                        left: 12,
                                        top: 12),
                                    child: Text(
                                      (model.cart[index].qty).toString(),
                                      style: CustomTextStyle.textFormFieldBlack,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.add,
                                      size: 24,
                                    ),
                                    onPressed: () {
                                      if (model.cart[index].price > 1) if (model
                                                  .cart[index].stock_count >=
                                              model.cart[index].qty &&
                                          (model.cart[index].stock_count -
                                                  model.cart[index].qty) !=
                                              0) {
                                        model.updateProduct(
                                            model.cart[index].id,
                                            model.cart[index].price,
                                            model.cart[index].qty + 1);
                                      } else {
                                        _showAlert(context);
                                      }
                                      // model.removeProduct(model.cart[index]);
                                    },
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                flex: 100,
              )
            ],
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            margin: EdgeInsets.only(right: 15, top: 10, bottom: 20),
            child: IconButton(
              padding: EdgeInsets.only(top: 4, bottom: 4),
              icon: Icon(
                Icons.close,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {
                model.removeProduct(model.cart[index].id);
                // model.removeProduct(model.cart[index]);
              },
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                color: primaryColor),
          ),
        )
      ],
    );
  }
}
