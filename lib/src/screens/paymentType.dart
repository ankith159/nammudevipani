import 'package:flutter/material.dart';
import 'package:foodexpress/providers/auth.dart';
import 'package:foodexpress/src/Widget/PaymentMethodListItemWidget.dart';
import 'package:foodexpress/src/screens/paymentPaystack.dart';
import 'package:foodexpress/src/screens/paymentRazorpay.dart';
import 'package:foodexpress/src/screens/paymentStripe.dart';
import 'package:foodexpress/src/shared/colors.dart';
import 'package:foodexpress/src/utils/CustomTextStyle.dart';
import 'package:provider/provider.dart';

import '../../main.dart';


class PaymentMethodsPage extends StatefulWidget {
  final orderID;
  final amount;
  PaymentMethodsPage({Key key, this.orderID,this.amount}) : super(key: key);

  @override
  _PaymentMethodsWidgetState createState() => _PaymentMethodsWidgetState();
}

class _PaymentMethodsWidgetState extends State<PaymentMethodsPage> {

  Future<bool> onWillPop() {
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final token = Provider.of<AuthProvider>(context, listen: true).token;
    final currencyName = Provider.of<AuthProvider>(context, listen: true).currencyname;
    final stripeKey = Provider.of<AuthProvider>(context, listen: true).stripekey;
    final stripeSecret = Provider.of<AuthProvider>(context, listen: true).stripesecret;
    return  WillPopScope(
        onWillPop: onWillPop,
        child:
      Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.popUntil(context, ModalRoute.withName('/'));
            }),
        elevation: 0,
        centerTitle: true,
        title: Text('Payment Type'),
      ),
      body: SingleChildScrollView(
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
                        'Payment Options',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:CustomTextStyle.textFormFieldMedium.copyWith(
                      color: Colors.black54,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('select your preferred payment mode'),
                    ),
                  ),
            SizedBox(height: 10),
            ListView(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              primary: false,
              children: <Widget>[
                // PaymentMethodListItemWidget(paymentMethod:'Stripe',logo: 'assets/images/stripe.png',description:'Click to pay with your Stripe' ,route: PaymentStripeMethodsPage(amount:widget.amount,OrderID:widget.orderID,customerToken: token,),),
                // SizedBox(height: 10),
                PaymentMethodListItemWidget(paymentMethod:'Razorpay',logo: 'assets/images/razorpay.png',description:'Click to pay with your Razorpay' ,route: PaymentRazorPay(amount:widget.amount,OrderID:widget.orderID,customerToken: token,),),
                SizedBox(height: 10),
                // PaymentMethodListItemWidget(paymentMethod:'Paystack',logo: 'assets/images/paystack.png',description:'Click to pay with your Paystack' ,route: PaymentPaystack(amount:widget.amount,OrderID:widget.orderID,customerToken: token,),),
              ],
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
                        'Cash on delivery',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:CustomTextStyle.textFormFieldMedium.copyWith(
                            color: Colors.black54,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('select your preferred payment mode'),
                    ),
                  ),
            ListView(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              primary: false,
              children: <Widget>[
                PaymentMethodListItemWidget(paymentMethod:'Cash on Delivery',logo: 'assets/images/cash_delivery.jpg',description:'Click to pay cash on delivery' ,route: MyHomePage(title:'My Order',tabsIndex: 1,),),
                SizedBox(height: 10),
                PaymentMethodListItemWidget(paymentMethod:'Pay on Pickup',logo: 'assets/images/pay_pickup.png',description:'Click to pay on pickup' ,route:MyHomePage(title:'My Order',tabsIndex: 1,),),
              ],
            ),
          ],
        ),
      ),
    ));
  }
}
