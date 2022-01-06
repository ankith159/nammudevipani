import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:foodexpress/providers/auth.dart';
import 'package:foodexpress/src/shared/colors.dart';
import 'package:foodexpress/src/utils/CustomTextStyle.dart';
import 'package:provider/provider.dart';

class PaymentPaystack extends StatefulWidget {
  String OrderID;
  String amount;
  String customerToken;
  PaymentPaystack({Key key,this.amount,this.OrderID, this.customerToken}) : super(key: key);
  @override
  _PaymentPaystackState createState() => _PaymentPaystackState();
}

// Pay public key
class _PaymentPaystackState extends State<PaymentPaystack> {
  String payStackKey;
  String currency;
  String customerEmail;
  var _paystack = PaystackPlugin();
  @override
  void initState() {
    currency = Provider.of<AuthProvider>(context,listen: false).currency;
    payStackKey = Provider.of<AuthProvider>(context,listen: false).paystackKey;
    customerEmail = Provider.of<AuthProvider>(context,listen: false).userEmail;

    _paystack.initialize(
        publicKey: payStackKey);
    super.initState();
  }

  Dialog successDialog(context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0)), //this right here
      child: Container(
        height: 350.0,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.check_box,
                color: Colors.black45,
                size: 90,
              ),
              SizedBox(height: 15),
              Text(
                'Payment has successfully',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                'been made',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              Text(
                "Your payment has been successfully",
                style: TextStyle(fontSize: 13),
              ),
              Text("processed.", style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return successDialog(context);
      },
    );
  }

  Dialog errorDialog(context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0)), //this right here
      child: Container(
        height: 350.0,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.cancel,
                color: Colors.red,
                size: 90,
              ),
              SizedBox(height: 15),
              Text(
                'Failed to process payment',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              Text(
                "Error in processing payment, please try again",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return errorDialog(context);
      },
    );
  }

  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }
    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }

  chargeCard() async {
    Charge charge = Charge()
      ..amount = int.parse(widget.amount)*100
      ..reference = _getReference()
      // or ..accessCode = _getAccessCodeFrmInitialization()
      ..email = customerEmail;
    CheckoutResponse response = await _paystack.checkout(
      context,
      method: CheckoutMethod.card, // Defaults to CheckoutMethod.selectable
      charge: charge,
    );
    if (response.status == true) {
      _showDialog();
    } else {
      _showErrorDialog();
    }
  }
  Future<void> _showAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('PayStack'),
          content: Text('Please configure your payment settings payStack'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "PayStack Payment",
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body:
      SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 0),
                leading: Icon(
                  Icons.payment,
                  color: Theme.of(context).hintColor,
                ),
                title: Text(
                  'Payment',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:CustomTextStyle.textFormFieldMedium.copyWith(
                      color: Colors.black54,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Click your Payment '),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child:
              Container(
                  height: 100,
                  decoration: BoxDecoration(
                    image: new DecorationImage(
                      image: new ExactAssetImage('assets/images/paystack.png'),
                      fit: BoxFit.contain,
                    ),
                  )
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 0),
                leading: Icon(
                  Icons.monetization_on,
                  color: Theme.of(context).hintColor,
                ),
                title: Text(
                  'Total Amount $currency ${widget.amount}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:CustomTextStyle.textFormFieldMedium.copyWith(
                      color: Colors.black54,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            InkWell(
                onTap: () {
                  if(payStackKey !=null){
                    chargeCard();
                  }else{
                    _showAlert(context);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(left:18.0,right: 18),
                  child: Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width - 50.0,
                      height: 50.0,
                      decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(25.0),
                          color: primaryColor),
                      child: Center(
                          child: Text('Payment',
                              style: TextStyle(
                                  fontFamily: 'nunito',
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)))),
                ))

          ],
        ),
      ),
    );
  }
}
