import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:foodexpress/config/api.dart';
import 'package:foodexpress/providers/auth.dart';
import 'package:foodexpress/src/shared/colors.dart';
import 'package:foodexpress/src/utils/CustomTextStyle.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;

import '../../main.dart';


class PaymentRazorPay extends StatefulWidget {
  String OrderID;
  String amount;
  String customerToken;
  PaymentRazorPay({Key key,this.amount,this.OrderID, this.customerToken}) : super(key: key);
  @override
  _PaymentRazorPay createState() => _PaymentRazorPay();
}

class _PaymentRazorPay extends State<PaymentRazorPay> {

  Razorpay razorpay;
  String razorpayKey;
  String sitename;
  String currency;
  static String api =  FoodApi.baseApi;

  @override
  void initState() {
    super.initState();
    currency = Provider.of<AuthProvider>(context,listen: false).currency;
    razorpayKey = Provider.of<AuthProvider>(context,listen: false).razorpayKey;
    sitename = Provider.of<AuthProvider>(context,listen: false).sitename;
    razorpay = new Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlerPaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlerErrorFailure);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handlerExternalWallet);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    razorpay.clear();
  }

  void openCheckout(){
    var options = {
      "key" : razorpayKey,
      "amount" : num.parse(widget.amount)*100,
      "name" : sitename,
      "description" : 'Order ID '+ widget.OrderID.toString(),
      'prefill': {'contact': '', 'email': ''},
      "external" : {
        "wallets" : ["paytm"]
      }
    };

    try{
      razorpay.open(options);

    }catch(e){
      razorpay.clear();
      print(e.toString());
    }

  }

  Future<void> handlerPaymentSuccess(PaymentSuccessResponse response) async {
    Toast.show("Pament success", context);
    final url = "$api/orders/payment";
    Map<String, String> body = {
      'order_id': widget.OrderID,
      'amount': widget.amount,
      'payment_method': '20',
      'payment_transaction_id': response.paymentId,
    };

    final responseBody = await http.post(Uri.parse(url), body: body,headers: {HttpHeaders.authorizationHeader: 'Bearer ${widget.customerToken}'});
    if(responseBody.statusCode == 200){
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MyHomePage(title:'My Order',tabsIndex: 1,)));
    }
  }

  void handlerErrorFailure(PaymentFailureResponse response){
    print(response);
    print("Pament error");
    Toast.show("Pament error", context);
  }

  void handlerExternalWallet(){
    print("External Wallet");
    Toast.show("External Wallet", context);
  }
  Future<void> _showAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Razorpay'),
          content: Text('Please configure your payment settings razorpay'),
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
        title: Text("Razorpay Payment"),
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
                    image: new ExactAssetImage('assets/images/razorpay.png'),
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
                  if(razorpayKey !=null && razorpayKey != ''){
                    openCheckout();
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