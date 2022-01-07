import 'dart:ffi';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodexpress/config/api.dart';
import 'package:foodexpress/main.dart';
import 'package:foodexpress/providers/auth.dart';
import 'package:foodexpress/src/Widget/CircularLoadingWidget.dart';
import 'package:foodexpress/src/screens/ChangePasswordPage.dart';
import 'package:foodexpress/src/screens/EditProfilePage.dart';
import 'package:foodexpress/src/shared/colors.dart';
import 'package:foodexpress/src/utils/CustomTextStyle.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({
    Key key,
  }) : super(key: key);
  @override
  _ProfilePageState createState() {
    return new _ProfilePageState();
  }
}

class _ProfilePageState extends State<ProfilePage> {
  GlobalKey<RefreshIndicatorState> refreshKey;

  String api = FoodApi.baseApi;
  Map<String, dynamic> result = {
    "name": '',
    "email": ' ',
    "image": '',
    "username": '',
    "phone": ' ',
    "address": ' '
  };
  Future<Void> deviceTokenUpdate(token) async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    var deviceToken = storage.getString('deviceToken');
    final url = "$api/device?device_token=$deviceToken";
    final response = await http.put(Uri.parse(url), headers: {
      HttpHeaders.acceptHeader: "application/json",
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });
  }

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
        result['name'] = resBody['data']['name'];
        result['email'] = resBody['data']['email'];
        result['username'] = resBody['data']['username'];
        result['phone'] = resBody['data']['phone'];
        result['address'] = resBody['data']['address'];
        result['balance'] = resBody['data']['balance'];
        result['mystatus'] = resBody['data']['mystatus'];
        result['image'] = resBody['data']['image'];
      });
    } else {
      throw Exception('Failed to data');
    }
    return "Sucess";
  }

  bool userSub;
  Future<String> getmysubStatus(token) async {
    final url = "$api/isUserSubscribed";
    var response = await http.get(Uri.parse(url), headers: {
      HttpHeaders.authorizationHeader: 'Bearer $token',
      HttpHeaders.contentTypeHeader: "application/json; charset=utf-8"
    });
    var resBody = json.decode(response.body);
    print(resBody);
    if (response.statusCode == 200) {
      setState(() {
        userSub = resBody['subscription'];
      });
    } else {
      throw Exception('Failed to data');
    }
    return "Sucess";
  }

  List avalsub = [];
  Future<String> getmysub(token) async {
    final url = "$api/getAllSubscriptions";
    var response = await http.get(Uri.parse(url), headers: {
      HttpHeaders.authorizationHeader: 'Bearer $token',
      HttpHeaders.contentTypeHeader: "application/json; charset=utf-8"
    });
    var resBody = json.decode(response.body);
    print(resBody);
    if (response.statusCode == 200) {
      setState(() {
        avalsub = resBody['data'];
      });
    } else {
      throw Exception('Failed to data');
    }
    return "Sucess";
  }

  Future<Null> refreshList(String token) async {
    setState(() {
      getmyProfile(token);
    });
  }

  void _showDialog(BuildContext context, {String title, String msg}) {
    final Dialog = AlertDialog(
      title: Text(title),
      content: Text(msg),
      actions: <Widget>[
        RaisedButton(
          color: Colors.teal,
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Close',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        )
      ],
    );
    showDialog(context: context, builder: (x) => Dialog);
  }

  var order_id = DateTime.now().millisecondsSinceEpoch.toString();
  Razorpay razorpay;
  String razorpayKey;
  String sitename;
  String currency;
  var token;

  @override
  void initState() {
    super.initState();
    token = Provider.of<AuthProvider>(context, listen: false).token;
    getmyProfile(token);
    deviceTokenUpdate(token);
    getmysub(token);
    getmysubStatus(token);

    currency = Provider.of<AuthProvider>(context, listen: false).currency;
    razorpayKey = Provider.of<AuthProvider>(context, listen: false).razorpayKey;
    sitename = Provider.of<AuthProvider>(context, listen: false).sitename;
    razorpay = new Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlerPaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlerErrorFailure);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handlerExternalWallet);
  }

  var total_order_amount;
  var subscription_id;
  Future<void> handlerPaymentSuccess(PaymentSuccessResponse response) async {
    Fluttertoast.showToast(msg: "Payment success");
    submitOrder(response.paymentId, total_order_amount, subscription_id, token);
    getmysubStatus(token);
  }

  Future<String> submitOrder(
      razorpay_payment_id, total_order_amount, subscription_id, token) async {
    var body = json.encode({
      "merchant_order_id": order_id,
      "razorpay_payment_id": razorpay_payment_id,
      "total_order_amount": total_order_amount,
      "subscription_id": subscription_id,
    });
    final url = "$api/updatesubscription";
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
    } else {
      throw Exception('Failed to data');
    }
    return "Sucess";
  }

  void handlerErrorFailure(PaymentFailureResponse response) {
    print(response);
    print("Pament error");
    Fluttertoast.showToast(msg: "Pament error");
    // Toast.show("Pament error", context);
  }

  void handlerExternalWallet() {
    print("External Wallet");
    Fluttertoast.showToast(msg: "External Wallet");
    // Toast.show("External Wallet", context);
  }

  final double circleRadius = 120.0;

  Future<void> submit() async {
    var result =
        await Provider.of<AuthProvider>(context, listen: false).logOut();
    if (result) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    return Scaffold(
        backgroundColor: primaryColor2,
        body: RefreshIndicator(
            key: refreshKey,
            onRefresh: () async {
              await refreshList(token);
            },
            child: result['name'] == ''
                ? CircularLoadingWidget(
                    height: 500,
                    subtitleText: 'profile not found',
                    img: 'assets/shopping.png',
                  )
                : ListView(
                    children: <Widget>[
                      Container(
                        height: 270,
                        width: 180,
                        color: primaryColor2,
                        child: Stack(children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Stack(
                              alignment: Alignment.topCenter,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: circleRadius / 2.0,
                                  ),

                                  ///here we create space for the circle avatar to get ut of the box
                                  child: Container(
                                    height: 230.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15.0),
                                      color: Colors.white,
                                    ),
                                    width: double.infinity,
                                    child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 15.0, bottom: 15.0),
                                        child: Column(
                                          children: <Widget>[
                                            SizedBox(
                                              height: circleRadius / 2,
                                            ),
                                            Text(
                                              result['name'],
                                              style: TextStyle(
                                                  fontFamily: 'Google Sans',
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 22.0),
                                            ),
                                            SizedBox(
                                              height: 10.0,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Column(
                                                    children: <Widget>[
                                                      Text(
                                                        result['balance'],
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Google Sans',
                                                          fontSize: 20.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Credit',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Google Sans',
                                                          fontSize: 15.0,
                                                          color: Colors.black54,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        )),
                                  ),
                                ),

                                ///Image Avatar
                                Container(
                                  width: circleRadius,
                                  height: circleRadius,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: Center(
                                      child: Container(
                                        child: CircleAvatar(
                                          radius: 50,
                                          backgroundImage: result['image'] !=
                                                  null
                                              ? NetworkImage(result['image'])
                                              : AssetImage('assets/steak.png'),
                                        ),

                                        /// replace your image with the Icon
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          InfoCard(
                            text: result['username'],
                            icon: Icons.perm_identity,
                            onPressed: () async {},
                          ),
                          InfoCard(
                            text: result['email'],
                            icon: Icons.mail_outline,
                            onPressed: () async {
                              final emailAddress = 'mailto:${result['email']}';
                              if (await canLaunch(emailAddress)) {
                                await launch(emailAddress);
                              } else {
                                _showDialog(
                                  context,
                                  title: 'Sorry',
                                  msg: 'please try again ',
                                );
                              }
                            },
                          ),
                          InfoCard(
                            text: result['phone'],
                            icon: Icons.phone,
                            onPressed: () async {
                              String removeSpaceFromPhoneNumber =
                                  result['phone'].replaceAll(
                                      new RegExp(r"\s+\b|\b\s"), "");
                              final phoneCall =
                                  'tel:$removeSpaceFromPhoneNumber';

                              if (await canLaunch(phoneCall)) {
                                await launch(phoneCall);
                              } else {
                                _showDialog(
                                  context,
                                  title: 'Sorry',
                                  msg: 'please try again ',
                                );
                              }
                            },
                          ),
                          InfoCard(
                            text: result['address'] ?? '',
                            icon: Icons.location_on,
                            onPressed: () {},
                          ),
                          createPasswordItem(),
                          createEditItem(),
                          createLogoutItem(),
                          SizedBox(
                            height: 20,
                          ),
                          userSub == null
                              ? Container()
                              : userSub
                                  ? ListTile(
                                      title: Text(
                                      'Subscribed',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ))
                                  : Column(
                                      children: [
                                        ListTile(
                                            title: Text(
                                          'Not Subscribed',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )),
                                        Divider(),
                                        ListTile(
                                            title: Text(
                                          'Select Subscription plan',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600),
                                        )),
                                      ],
                                    ),
                          userSub == null
                              ? Container()
                              : userSub
                                  ? Container()
                                  : Column(
                                      children: List.generate(
                                          avalsub.length,
                                          (index) => Container(
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 3),
                                                child: ListTile(
                                                  tileColor:
                                                      Colors.lightGreen[50],
                                                  title: Text(
                                                    avalsub[index]['title'],
                                                  ),
                                                  subtitle: Text(
                                                      avalsub[index]['price']),
                                                  onTap: () {
                                                    openCheckout(num.parse(
                                                        avalsub[index]
                                                            ['price']));
                                                  },
                                                ),
                                              )),
                                    )
                        ],
                      ),
                    ],
                  )));
  }

  void openCheckout(num amount) {
    var options = {
      "key": razorpayKey,
      "amount": amount * 100,
      "name": sitename,
      "description": 'Order ID ' + order_id,
      'prefill': {'contact': '', 'email': ''},
      "external": {
        "wallets": ["paytm"]
      }
    };

    try {
      razorpay.open(options);
    } catch (e) {
      razorpay.clear();
      print(e.toString());
    }
  }

  createLogoutItem() {
    return Builder(builder: (context) {
      return GestureDetector(
        onTap: () => submit(),
        child: Card(
          color: primaryColor2,
          elevation: 0.8,
          margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
          child: Row(
            children: <Widget>[
              SizedBox(
                height: 58,
                width: 15,
              ),
              Image(
                image: AssetImage('assets/images/ic_logout.png'),
                width: 40,
                height: 40,
                color: Colors.black87,
              ),
              SizedBox(
                width: 20,
              ),
              Text('Logout',
                  style: TextStyle(
                    fontFamily: 'Google Sans',
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  )),
              Spacer(
                flex: 1,
              ),
              Icon(
                Icons.navigate_next,
                color: Colors.black87,
              )
            ],
          ),
        ),
      );
    });
  }

  createPasswordItem() {
    return Builder(builder: (context) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => ChangePasswordPage()));
        },
        child: Card(
          color: primaryColor2,
          elevation: 0.8,
          margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
          child: Row(
            children: <Widget>[
              SizedBox(
                height: 58,
                width: 20,
              ),
              Icon(Icons.lock_outline),
              SizedBox(
                width: 20,
              ),
              Text('Change Password',
                  style: TextStyle(
                    fontFamily: 'Google Sans',
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  )),
              Spacer(
                flex: 1,
              ),
              Icon(
                Icons.navigate_next,
                color: Colors.black87,
              )
            ],
          ),
        ),
      );
    });
  }

  createEditItem() {
    return Builder(builder: (context) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => EditProfilePage(
                        userdata: result,
                      )));
        },
        child: Card(
          color: primaryColor2,
          elevation: 0.8,
          margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
          child: Row(
            children: <Widget>[
              SizedBox(
                height: 58,
                width: 20,
              ),
              Icon(Icons.edit),
              SizedBox(
                width: 20,
              ),
              Text('Edit Profile',
                  style: TextStyle(
                    fontFamily: 'Google Sans',
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  )),
              Spacer(
                flex: 1,
              ),
              Icon(
                Icons.navigate_next,
                color: Colors.black87,
              )
            ],
          ),
        ),
      );
    });
  }
}

class InfoCard extends StatelessWidget {
  final String text;
  final IconData icon;
  Function onPressed;

  InfoCard({@required this.text, @required this.icon, this.onPressed});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        color: primaryColor2,
        elevation: 0.8,
        margin: const EdgeInsets.only(bottom: 10, left: 25, right: 25),
        child: ListTile(
          leading: Icon(
            icon,
            color: Color(0xff0E0F19),
          ),
          title: Text(
            text,
            style: TextStyle(
              fontFamily: 'Google Sans',
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
