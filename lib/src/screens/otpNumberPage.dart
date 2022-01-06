import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodexpress/main.dart';
import 'package:foodexpress/models/cartmodel.dart';
import 'package:foodexpress/providers/auth.dart';
import 'package:foodexpress/src/screens/CheckOutPage.dart';
import 'package:foodexpress/src/Widget/notification_text.dart';
import 'package:foodexpress/src/shared/colors.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:numeric_keyboard/numeric_keyboard.dart';

class OtpIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OTP'),
        leading: Container(),
      ),
      body: Center(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 0.0),
            child: OtpNumberPage(),
          ),
        ),
      ),
    );
  }
}

class OtpNumberPage extends StatefulWidget {
  OtpNumberPage({Key key, this.title, this.verId}) : super(key: key);

  final String title, verId;

  @override
  _OtpNumberPageState createState() => _OtpNumberPageState();
}

class _OtpNumberPageState extends State<OtpNumberPage> {
  TextEditingController otpController = TextEditingController();
  ProgressDialog verifiedDialog, pr;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  signInMobile(context) async {
    verifiedDialog = ProgressDialog(context);

    var _credential = PhoneAuthProvider.credential(
      verificationId: widget.verId,
      smsCode: otpController.text,
    );
    verifiedDialog.style(
      message: 'Verifying the number',
    );
    await verifiedDialog.show();
    firebaseAuth.signInWithCredential(_credential).then((result) async {
      verifiedDialog.hide();

      if (result.user != null) {
        var cartData = ScopedModel.of<CartModel>(context, rebuildOnChange: true)
            .totalQunty;
        if (cartData != 0) {
          Navigator.of(context).push(
              new MaterialPageRoute(builder: (context) => CheckOutPage()));
        } else {
          Navigator.of(context)
              .push(new MaterialPageRoute(builder: (context) => MyHomePage()));
        }
      } else {
        _showAlert(context);
      }
    });
  }

  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(Icons.keyboard_arrow_left, color: Colors.black),
            ),
            Text(
              'Back',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Future<void> submit() async {
  //   var result = await signInMobile();
  //   print(result);
  // }

  Future<void> _showAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('User Login'),
          content: Consumer<AuthProvider>(
            builder: (context, provider, child) =>
                provider.notification ?? NotificationText(''),
          ),
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

  String text = '';
  void _onKeyboardTap(String value) {
    setState(() {
      text = text + value;
    });
  }

  otpNumberWidget(int position) {
    try {
      return Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 0),
            borderRadius: const BorderRadius.all(Radius.circular(8))),
        child: Center(
            child: Text(
          text[position],
          style: TextStyle(color: Colors.black),
        )),
      );
    } catch (e) {
      return Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 0),
            borderRadius: const BorderRadius.all(Radius.circular(8))),
      );
    }
  }

  List otp = [];
  List<Widget> widgets;
  String otpLimit;
  void initState() {
    super.initState();
    otpLimit = Provider.of<AuthProvider>(context, listen: false).otpLimit;
    for (var i = 0; i < int.parse(otpLimit); i++) {
      otp.add(i);
    }
  }

  @override
  Widget build(BuildContext context) {
    final _sitename = Provider.of<AuthProvider>(context).sitename;
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Enter ' +
                                otpLimit +
                                ' digits verification code sent to your email or phone',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 26,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: PinInputTextField(
                            pinLength: 6,
                            decoration: BoxLooseDecoration(
                              strokeColorBuilder: PinListenColorBuilder(
                                Colors.cyan,
                                Colors.green,
                              ),
                            ),
                            controller: otpController,
                            textInputAction: TextInputAction.go,
                            keyboardType: TextInputType.number,
                            onSubmit: (pin) {
                              signInMobile(context);
                            },
                            enableInteractiveSelection: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: RaisedButton(
                      onPressed: () {
                        signInMobile(context);
                      },
                      color: primaryColor,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(14))),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Confirm',
                              style: TextStyle(color: Colors.white),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(20)),
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 16,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  // NumericKeyboard(
                  //   onKeyboardTap: _onKeyboardTap,
                  //   textColor: Colors.amberAccent,
                  //   rightIcon: Icon(
                  //     Icons.backspace,
                  //     color: Colors.black,
                  //   ),
                  //   rightButtonFn: () {
                  //     setState(() {
                  //       text = text.substring(0, text.length - 1);
                  //     });
                  //   },
                  // )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
