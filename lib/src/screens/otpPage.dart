import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodexpress/providers/auth.dart';
import 'package:foodexpress/src/screens/otpNumberPage.dart';
import 'package:foodexpress/src/Widget/notification_text.dart';
import 'package:foodexpress/src/screens/signupPage.dart';
import 'package:foodexpress/src/shared/colors.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

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
            child: OtpPage(),
          ),
        ),
      ),
    );
  }
}

class OtpPage extends StatefulWidget {
  OtpPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  ProgressDialog sendOtpDialog, otpSentDialog, verifiedDialog, pr;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String verId='';
  TextEditingController otpController = TextEditingController();
  sendOtpToMobile(context) async {
    sendOtpDialog = ProgressDialog(context);
    otpSentDialog = ProgressDialog(context);
    verifiedDialog = ProgressDialog(context);
    sendOtpDialog.style(
      message: 'Sending Otp',
    );

    await sendOtpDialog.show();
    try {
      firebaseAuth.verifyPhoneNumber(
          phoneNumber: '+91' + "${phoneController.text}",
          // phoneNumber: "+919493757509",

          timeout: Duration(seconds: 60),
          verificationCompleted: (AuthCredential authCredential) {
            // print(authCredential);
            firebaseAuth
                .signInWithCredential(authCredential)
                .then((result) async {
              verifiedDialog.style(
                message: 'Verified',
              );

              await verifiedDialog.show();
              Future.delayed(Duration(seconds: 2), () {
                verifiedDialog.hide();
              });
            });
          },
          verificationFailed: (authException) {
            sendOtpDialog.hide();
            Fluttertoast.showToast(msg: '$authException');
            // print(authException);
          },
          codeSent: (String verificationId, [int forceResendingToken]) async {
            verId = verificationId;
            sendOtpDialog.hide();
            otpSentDialog.style(
              message: 'Otp Sent',
            );

            await otpSentDialog.show();

            Future.delayed(Duration(seconds: 1), () {
              otpSentDialog.hide();
              Navigator.of(context).push(
                new MaterialPageRoute(
                  builder: (context) => OtpNumberPage(
                    title: 'food',
                    verId: verId,
                  ),
                ),
              );
            });
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            verificationId = verificationId;
            // print(verificationId);
          });
    } catch (e) {
      sendOtpDialog.hide();
      Fluttertoast.showToast(msg: 'Try Again');
    }
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
            Text('Back',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }

  Future<void> submit(value) async {
    var result = await sendOtpToMobile(context);
    // var result =await Provider.of<AuthProvider>(context,listen: false).Otpregister(value);
    print(result);
    if (result) {
      Navigator.of(context).push(
        new MaterialPageRoute(
          builder: (context) => OtpNumberPage(
            title: 'food',
          ),
        ),
      );
    } else {
      _showAlert(context);
    }
  }

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

  TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final _sitename = Provider.of<AuthProvider>(context).sitename;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        child: Stack(
                          children: <Widget>[
                            Center(
                              child: Container(
                                height: 240,
                                constraints:
                                    const BoxConstraints(maxWidth: 500),
                                margin: const EdgeInsets.only(top: 100),
                                decoration: const BoxDecoration(
                                    color: Color(0xFFE1E0F5),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30))),
                              ),
                            ),
                            Center(
                              child: Container(
                                  constraints:
                                      const BoxConstraints(maxHeight: 340),
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Image.asset('assets/login.png')),
                            ),
                          ],
                        ),
                      ),
                      Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text('OTP Login',
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.w800)))
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: <Widget>[
                      Container(
                          constraints: const BoxConstraints(maxWidth: 500),
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(children: <TextSpan>[
                              TextSpan(
                                  text: 'We will send you an ',
                                  style: TextStyle(color: Colors.black)),
                              TextSpan(
                                  text: 'One Time Password ',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text: 'on this email or number',
                                  style: TextStyle(color: Colors.black)),
                            ]),
                          )),
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 5),
                              child: Text(
                                'Enter your email or phone',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                            Container(
                              height: 50,
                              constraints: const BoxConstraints(maxWidth: 500),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: CupertinoTextField(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(4))),
                                controller: phoneController,
                                clearButtonMode: OverlayVisibilityMode.editing,
                                keyboardType: TextInputType.text,
                                maxLines: 1,
                                placeholder: 'Email or phone',
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
                            if (phoneController.text.isNotEmpty) {
                              sendOtpToMobile(context);
                            }
                          },
                          color: primaryColor,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(14))),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Next',
                                  style: TextStyle(color: Colors.white),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(20)),
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
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
