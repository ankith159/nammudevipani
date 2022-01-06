// import 'package:flutter/material.dart';
// import 'package:flutter_credit_card/credit_card_widget.dart';
// import 'package:foodexpress/main.dart';
// import 'package:foodexpress/providers/auth.dart';
// import 'package:foodexpress/services/payment-service.dart';
// import 'package:foodexpress/src/shared/colors.dart';
// import 'package:foodexpress/src/utils/CustomTextStyle.dart';
// import 'package:progress_dialog/progress_dialog.dart';
// import 'package:provider/provider.dart';


// class PaymentStripeMethodsPage extends StatefulWidget {
//   String OrderID;
//   String amount;
//   String customerToken;
//   PaymentStripeMethodsPage({Key key,this.amount,this.OrderID, this.customerToken}) : super(key: key);

//   @override
//   _PaymentMethodsStripeWidgetState createState() => _PaymentMethodsStripeWidgetState();
// }

// class _PaymentMethodsStripeWidgetState extends State<PaymentStripeMethodsPage> {

//   onItemPress(BuildContext context, int index) async {payViaNewCard(context);}
//   payViaNewCard(BuildContext context) async {
//     ProgressDialog dialog = new ProgressDialog(context);
//     dialog.style(
//         message: 'Please wait...'
//     );
//     await dialog.show();
//     var amount = (double.tryParse('${widget.amount}') *100).toInt();
//     var response = await StripeService.payWithNewCard(
//         amount: amount.toString(),
//         currency: 'USD',
//         orderId: widget.OrderID,
//         customerToken: widget.customerToken,
//     );
//     await dialog.hide();
//     if(response.success == true){
//       _showDialog("SUCCESSFUL", "assets/success_logo.png");
//     }else {
//       _showDialog("UNSUCCESSFUL", "assets/unsuccess_logo.png");
//     }
//     Scaffold.of(context).showSnackBar(
//         SnackBar(
//           content: Text(response.message),
//           duration: new Duration(milliseconds: response.success == true ? 1200 : 3000),
//         )
//     );
//   }

//   void _showDialog(String message, String logo) {
//     // flutter defined function
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         // return object of type Dialog
//         return AlertDialog(
//           title: Center(child: new Text("Payment Status")),
//           content: new Container(
//             height: 100.0,
//             child: new Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: <Widget>[
//                 new Image.asset(
//                   "$logo",
//                   height: 50.0,
//                   width: 50.0,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(top: 20.0),
//                   child: new Text(
//                     "$message",
//                     style: new TextStyle(
//                         fontSize: 20.0,
//                         color: Colors.green,
//                         fontWeight: FontWeight.w400,
//                         fontFamily: "Roboto"),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           actions: <Widget>[
//             // usually buttons at the bottom of the dialog
//             new FlatButton(
//               child: new Text("My order"),
//               onPressed: () {
//                 Navigator.push(
//                     context, MaterialPageRoute(builder: (context) => MyHomePage(title:'My Order',tabsIndex: 1,)));
//                 },
//             ),
//           ],
//         );
//       },
//     );
//   }
//   initAuthProvider(context) async {
//     Provider.of<AuthProvider>(context,listen: false).initAuthProvider();
//   }
//   @override
//   void initState() {
//     super.initState();
//     final stripesecret = Provider.of<AuthProvider>(context,listen: false).stripesecret;
//     final stripekey = Provider.of<AuthProvider>(context,listen: false).stripekey;
//     StripeService(stripesecret,stripekey);
//     StripeService.init();
//   }

//   @override
//   Widget build(BuildContext context) {
//     ThemeData theme = Theme.of(context);
//     final currency = Provider.of<AuthProvider>(context).currency;
//     final sitename = Provider.of<AuthProvider>(context).sitename;

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: primaryColor,
//         elevation: 0,
//         centerTitle: true,
//         title: Text('Stripe Payment'),
//       ),
//       body:
//       SingleChildScrollView(
//         padding: EdgeInsets.symmetric(vertical: 10),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.start,
//           mainAxisSize: MainAxisSize.max,
//           children: <Widget>[
//             SizedBox(height: 15),
//              Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: ListTile(
//                       contentPadding: EdgeInsets.symmetric(vertical: 0),
//                       leading: Icon(
//                         Icons.payment,
//                         color: Theme.of(context).hintColor,
//                       ),
//                       title: Text(
//                         'Payment',
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style:CustomTextStyle.textFormFieldMedium.copyWith(
//                       color: Colors.black54,
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold),
//                       ),
//                       subtitle: Text('Click your card information'),
//                     ),
//                   ),
//             SizedBox(height: 10),
//             ListView.separated(
//               shrinkWrap: true,
//                 itemBuilder: (context, index) {
//                   return InkWell(
//                     onTap: () {
//                       onItemPress(context, index);
//                     },
//                     child: CreditCardWidget(
//                       cardNumber: '4242424242424242',
//                       expiryDate: '04/24',
//                       cardHolderName: sitename,
//                       cvvCode: '424',
//                       showBackView: false,
//                       onCreditCardWidgetChange: (a){},
//                     ),
//                   );
//                 },
//                 separatorBuilder: (context, index) => Divider(
//                   color: theme.primaryColor,
//                 ),
//                 itemCount: 1
//             ),            Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//                     child: ListTile(
//                       contentPadding: EdgeInsets.symmetric(vertical: 0),
//                       leading: Icon(
//                         Icons.monetization_on,
//                         color: Theme.of(context).hintColor,
//                       ),
//                       title: Text(
//                         'Total Amount $currency ${widget.amount}',
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style:CustomTextStyle.textFormFieldMedium.copyWith(
//                             color: Colors.black54,
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
// }
