import 'dart:io';

import 'package:flutter/material.dart';
import 'package:foodexpress/config/api.dart';
import 'package:foodexpress/main.dart';
import 'package:foodexpress/providers/auth.dart';
import 'package:foodexpress/src/screens/paymentType.dart';
import 'package:foodexpress/src/shared/Product.dart';
import 'package:foodexpress/src/shared/colors.dart';
import 'package:foodexpress/src/utils/CustomTextStyle.dart';
import 'package:foodexpress/src/utils/validate.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:foodexpress/models/cartmodel.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:convert';

class CheckOutPage extends StatefulWidget {
  @override
  _CheckOutPageState createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String api = FoodApi.baseApi;
  String _OrderSucess;
  String _OrderAmount;
  String OrderFile;
  String _OrderId;
  File _image;
  String base64Image;
  String fileName;

  String customer_mobile;
  String delivery_address;
  String customer_lat;
  String customer_long;
  String remarks;
  double delivery_charge;
  double total;
  String token;
  Future<String> submitOrder(
      cart,
      customer_mobile,
      delivery_address,
      total,
      ShopID,
      delivery_charge,
      remarks,
      customer_lat,
      customer_long,
      token) async {
    List<Map> items = new List();
    List<Map> itemsOption = new List();
    cart.forEach((element) {
      if (element.options != null) {
        element.options.forEach((element) => itemsOption.add(Options(
                id: element.id.toString(),
                name: element.name,
                price: element.price)
            .TojsonData()));
      }
    });
    cart.forEach((element) => items.add(ItemProduct(
            shop_id: ShopID,
            product_id: element.id,
            unit_price: element.price,
            discounted_price: 0.0,
            quantity: element.qty,
            shop_product_variation_id: element.variation_id,
            options: itemsOption)
        .TojsonData()));
    var body = json.encode({
      "items": json.encode(items),
      "mobile": customer_mobile,
      "address": delivery_address,
      "delivery_charge": delivery_charge,
      "lat": customer_lat,
      "long": customer_long,
      "remarks": 'remarks',
      "total": total,
      "shop_id": ShopID,
      "image": base64Image != null ? base64Image : '',
      "fileName": fileName != null ? fileName : '',
    });
    final url = "$api/orders";
    var response = await http.post(Uri.parse(url),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          HttpHeaders.contentTypeHeader: "application/json; charset=utf-8",
        },
        body: body);
    print(response);
    print(response.body);
    var resBody = json.decode(response.body);
    print(resBody);
    if (response.statusCode == 200) {
      setState(() {
        _OrderSucess = resBody['message'];
        _OrderId = resBody['data']['order_id'].toString();
        _OrderAmount = resBody['data']['total_amount'].toString();
        showThankYouBottomSheet(
            context,
            resBody['message'],
            resBody['data']['order_id'].toString(),
            resBody['data']['total_amount'].toString());
        ScopedModel.of<CartModel>(context, rebuildOnChange: true).clearCart();
      });
    } else {
      _showAlert(context);
      throw Exception('Failed to data');
    }
    return "Sucess";
  }

  Future<void> _showAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create Order'),
          content: Text('Failed to data'),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Map<String, dynamic> user = {
    "name": '',
    "email": '',
    "image": '',
    "username": '',
    "phone": '',
    "address": ''
  };
  Future<String> getmyProfile(token) async {
    final url = "$api/me";

    var response = await http.get(Uri.parse(url), headers: {
      HttpHeaders.authorizationHeader: 'Bearer $token',
      HttpHeaders.contentTypeHeader: "application/json; charset=utf-8"
    });
    var resBody = json.decode(response.body);
    print(resBody);
    if (response.statusCode == 200) {
      setState(() {
        user['name'] = resBody['data']['name'];
        user['email'] = resBody['data']['email'];
        user['username'] = resBody['data']['username'];
        user['phone'] = resBody['data']['phone'];
        user['address'] = resBody['data']['address'];
        user['image'] = resBody['data']['image'];
      });
    } else {
      throw Exception('Failed to data');
    }
    return "Sucess";
  }

  Future<bool> onWillPop() {
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  bool _firstPress = true;
  @override
  void initState() {
    super.initState();
    _firstPress = true;
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    getmyProfile(token);
  }

  Location location = new Location();
  @override
  Widget build(BuildContext context) {
    final token = Provider.of<AuthProvider>(context, listen: true).token;
    final currency = Provider.of<AuthProvider>(context).currency;
    Future getImage() async {
      var _picker = ImagePicker();
      var img = await _picker.pickImage(source: ImageSource.gallery);
      _image = File(img.path);
      List<int> imageBytes = await _image.readAsBytesSync();
      setState(() {
        base64Image = base64Encode(imageBytes);
        fileName = _image.path.split("/").last;
      });
    }

    return ScopedModel.of<CartModel>(context, rebuildOnChange: true)
                .totalQunty ==
            0
        ? WillPopScope(
            onWillPop: onWillPop,
            child: Scaffold(
              key: _scaffoldKey,
              // resizeToAvoidBottomPadding: false,
              appBar: AppBar(
                backgroundColor: primaryColor,
                leading: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.popUntil(context, ModalRoute.withName('/'));
                    }),
                title: Text(
                  "Checkout",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              body: Builder(builder: (context) {
                return Column(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        child: ListView(
                          children: <Widget>[
                            Form(
                                key: _formKey,
                                child: Column(children: <Widget>[
                                  selectedAddressSection(user),
                                  Column(
                                    children: <Widget>[
                                      Container(
                                          child: Text(fileName != null
                                              ? fileName
                                              : '')),
                                      SizedBox(
                                        height: 6,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Align(
                                              alignment: Alignment.center,
                                              child: Text('Add Attachment')),
                                          Align(
                                            alignment: Alignment.center,
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.camera,
                                                size: 30.0,
                                              ),
                                              onPressed: () {
                                                getImage();
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  priceSection(currency),
                                ])),
                          ],
                        ),
                      ),
                      flex: 90,
                    ),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        child: RaisedButton(
                          onPressed: () async {
                            if (ScopedModel.of<CartModel>(context,
                                        rebuildOnChange: true)
                                    .totalCartValue <
                                250) {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: Text(
                                            'Minimum order value is Rs.250'),
                                      ));
                              return;
                            }
                            bool _serviceEnabled;
                            PermissionStatus _permissionGranted;
                            LocationData _locationData;

                            _serviceEnabled = await location.serviceEnabled();
                            if (!_serviceEnabled) {
                              _serviceEnabled = await location.requestService();
                              if (!_serviceEnabled) {
                                return;
                              }
                            }

                            _permissionGranted = await location.hasPermission();
                            if (_permissionGranted == PermissionStatus.denied) {
                              _permissionGranted =
                                  await location.requestPermission();
                              if (_permissionGranted !=
                                  PermissionStatus.granted) {
                                return;
                              }
                            }

                            _locationData = await location.getLocation();
                            print('location');
                            print(_locationData.latitude);
                            print(_locationData.longitude);
                            final form = _formKey.currentState;
                            if (form.validate()) {
                              if (_firstPress) {
                                _firstPress = false;
                                submitOrder(
                                    ScopedModel.of<CartModel>(context,
                                            rebuildOnChange: true)
                                        .cart,
                                    customer_mobile,
                                    delivery_address,
                                    ScopedModel.of<CartModel>(context,
                                            rebuildOnChange: true)
                                        .totalCartValue,
                                    ScopedModel.of<CartModel>(context,
                                            rebuildOnChange: true)
                                        .ShopID,
                                    ScopedModel.of<CartModel>(context,
                                            rebuildOnChange: true)
                                        .deliveryCharge,
                                    '',
                                    _locationData.latitude.toString(),
                                    _locationData.longitude.toString(),
                                    token);
                              }
                              if (_OrderSucess != null) {
                                ScopedModel.of<CartModel>(context,
                                        rebuildOnChange: true)
                                    .clearCart();
                                showThankYouBottomSheet(context, _OrderSucess,
                                    _OrderId, _OrderAmount);
                              }
                            }
                          },
                          child: Text(
                            "Place Order",
                            style: CustomTextStyle.textFormFieldMedium.copyWith(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                          color: primaryColor,
                          textColor: Colors.white,
                        ),
                      ),
                      flex: 10,
                    )
                  ],
                );
              }),
            ),
          )
        : Scaffold(
            key: _scaffoldKey,
            // resizeToAvoidBottomPadding: false,
            appBar: AppBar(
              backgroundColor: primaryColor,
              leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  }),
              title: Text(
                "Checkout",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            body: Builder(builder: (context) {
              return Column(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: ListView(
                        children: <Widget>[
                          Form(
                              key: _formKey,
                              child: Column(children: <Widget>[
                                selectedAddressSection(user),
                                Column(
                                  children: <Widget>[
                                    Container(
                                        child: Text(
                                            fileName != null ? fileName : '')),
                                    SizedBox(
                                      height: 6,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Align(
                                            alignment: Alignment.center,
                                            child: Text('Add Attachment')),
                                        Align(
                                          alignment: Alignment.center,
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.camera,
                                              size: 30.0,
                                            ),
                                            onPressed: () {
                                              getImage();
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                priceSection(currency),
                              ])),
                        ],
                      ),
                    ),
                    flex: 90,
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      child: RaisedButton(
                        onPressed: () {
                          final form = _formKey.currentState;
                          if (form.validate()) {
                            if (_firstPress) {
                              _firstPress = false;
                              submitOrder(
                                  ScopedModel.of<CartModel>(context,
                                          rebuildOnChange: true)
                                      .cart,
                                  customer_mobile,
                                  delivery_address,
                                  ScopedModel.of<CartModel>(context,
                                          rebuildOnChange: true)
                                      .totalCartValue,
                                  ScopedModel.of<CartModel>(context,
                                          rebuildOnChange: true)
                                      .ShopID,
                                  ScopedModel.of<CartModel>(context,
                                          rebuildOnChange: true)
                                      .deliveryCharge,
                                  '',
                                  '_555',
                                  '_6666',
                                  token);
                            }
                            if (_OrderSucess != null) {
                              ScopedModel.of<CartModel>(context,
                                      rebuildOnChange: true)
                                  .clearCart();
                              showThankYouBottomSheet(context, _OrderSucess,
                                  _OrderId, _OrderAmount);
                            }
                          }
                        },
                        child: Text(
                          "Place Order",
                          style: CustomTextStyle.textFormFieldMedium.copyWith(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                        color: primaryColor,
                        textColor: Colors.white,
                      ),
                    ),
                    flex: 10,
                  )
                ],
              );
            }),
          );
  }

  showThankYouBottomSheet(BuildContext context, resBody, orderId, amount) {
    return _scaffoldKey.currentState.showBottomSheet((context) {
      return Container(
        height: 400,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade200, width: 2),
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(16), topLeft: Radius.circular(16))),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Image(
                    image: AssetImage("assets/icons/ic_thank_you.png"),
                    width: 300,
                  ),
                ),
              ),
              flex: 5,
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 16, right: 16),
                child: Column(
                  children: <Widget>[
                    RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(children: [
                          TextSpan(
                            text:
                                "\n\nThank you for your purchase. Our company values each and every customer. We strive to provide state-of-the-art devices that respond to our clients’ individual needs. If you have any questions or feedback, please don’t hesitate to reach out.",
                            style: CustomTextStyle.textFormFieldMedium.copyWith(
                                fontSize: 14, color: Colors.grey.shade800),
                          )
                        ])),
                    SizedBox(
                      height: 24,
                    ),
                    new Container(
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          RaisedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MyHomePage(
                                            title: 'My Order',
                                            tabsIndex: 1,
                                          )));
                            },
                            padding: EdgeInsets.only(left: 35, right: 35),
                            child: Text(
                              "My Orders",
                              style: CustomTextStyle.textFormFieldMedium
                                  .copyWith(color: Colors.white),
                            ),
                            color: primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(24))),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          RaisedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PaymentMethodsPage(
                                            amount: amount,
                                            orderID: orderId,
                                          )));
                            },
                            padding: EdgeInsets.only(left: 35, right: 35),
                            child: Text(
                              "Pay Now",
                              style: CustomTextStyle.textFormFieldMedium
                                  .copyWith(color: Colors.white),
                            ),
                            color: primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(24))),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              flex: 10,
            )
          ],
        ),
      );
    },
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16), topRight: Radius.circular(16))),
        backgroundColor: Colors.white,
        elevation: 2);
  }

  selectedAddressSection(user) {
    return Container(
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4))),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              border: Border.all(color: Colors.grey.shade200)),
          padding: EdgeInsets.only(left: 12, top: 8, right: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 6,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    user['name'] != null ? user['name'] : '',
                    style: CustomTextStyle.textFormFieldSemiBold
                        .copyWith(fontSize: 14),
                  ),
                ],
              ),
              createAddressText(user['phone'], 6),
              createAddressText(user['address'], 6),
              SizedBox(
                height: 6,
              ),
              _phoneWidget(),
              _addressWidget(),
              SizedBox(
                height: 16,
              ),
              Container(
                color: Colors.grey.shade300,
                height: 1,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _phoneWidget() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Phone *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                  obscureText: false,
                  textAlign: TextAlign.start,
                  keyboardType: TextInputType.text,
                  style: TextStyle(
                    fontSize: 18,
                    height: 0.6,
                  ),
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 15),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54),
                    ),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black54)),
                    hintText: "Enter phone number",
                  ),
                  validator: (value) {
                    customer_mobile = value.trim();
                    return Validate.requiredField(value, 'Phone is required.');
                  })
            ],
          ),
        )
      ],
    );
  }

  Widget _addressWidget() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Delivery Address *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                  obscureText: false,
                  textAlign: TextAlign.start,
                  keyboardType: TextInputType.text,
                  style: TextStyle(
                    fontSize: 18,
                    height: 0.6,
                  ),
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 15),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54),
                    ),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black54)),
                    hintText: "Enter delivery address",
                  ),
                  validator: (value) {
                    delivery_address = value.trim();
                    return Validate.requiredField(
                        value, 'address is required.');
                  })
            ],
          ),
        )
      ],
    );
  }

  createAddressText(user, double topMargin) {
    return Container(
      margin: EdgeInsets.only(top: topMargin),
      child: Text(
        user != null ? user : '',
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.grey.shade800),
      ),
    );
  }

  priceSection(currency) {
    return Container(
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4))),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              border: Border.all(color: Colors.grey.shade200)),
          padding: EdgeInsets.only(left: 12, top: 8, right: 12, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 4,
              ),
              Text(
                "PRICE DETAILS",
                style: CustomTextStyle.textFormFieldMedium.copyWith(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 4,
              ),
              Container(
                width: double.infinity,
                height: 0.5,
                margin: EdgeInsets.symmetric(vertical: 4),
                color: Colors.grey.shade400,
              ),
              SizedBox(
                height: 8,
              ),
              createPriceItem(
                  "Order Total",
                  currency,
                  '${ScopedModel.of<CartModel>(context, rebuildOnChange: true).totalCartValue}',
                  Color(
                    0xff0E0F19,
                  )),
              createPriceItem(
                  "Delievery Charges",
                  currency,
                  '${ScopedModel.of<CartModel>(context, rebuildOnChange: true).deliveryCharge}',
                  Colors.teal.shade300),
              SizedBox(
                height: 8,
              ),
              Container(
                width: double.infinity,
                height: 0.5,
                margin: EdgeInsets.symmetric(vertical: 4),
                color: Colors.grey.shade400,
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Text(
                      "Total",
                      style: TextStyle(
                          color: Color(
                            0xff0E0F19,
                          ),
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                          "$currency" +
                              '${ScopedModel.of<CartModel>(context, rebuildOnChange: true).totalCartValue + ScopedModel.of<CartModel>(context, rebuildOnChange: true).deliveryCharge}',
                          style: TextStyle(
                              color: Color(
                                0xff0E0F19,
                              ),
                              fontSize: 14,
                              fontWeight: FontWeight.w500)))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  createPriceItem(String key, String currency, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            key,
            style: CustomTextStyle.textFormFieldMedium
                .copyWith(color: Colors.grey.shade700, fontSize: 12),
          ),
          Text(
            '$currency' + value,
            style: CustomTextStyle.textFormFieldMedium
                .copyWith(color: color, fontSize: 12),
          )
        ],
      ),
    );
  }
}
