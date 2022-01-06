// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/services.dart';
// import 'package:foodexpress/config/api.dart';
// import 'package:foodexpress/providers/auth.dart';
// import 'package:http/http.dart' as http;
// import 'package:stripe_payment/stripe_payment.dart';

// class StripeTransactionResponse {
//   String message;
//   bool success;
//   StripeTransactionResponse({this.message, this.success});
// }

// class StripeService {
//  static String stripesecret;
//  static String stripekey;
//   StripeService(Stripesecret,Stripekey) {
//     stripekey = Stripekey;
//     stripesecret = Stripesecret;
//   }
//   static String api =  FoodApi.baseApi;
//   static String apiBase = 'https://api.stripe.com/v1';
//   static String paymentApiUrl = '${StripeService.apiBase}/payment_intents';
//   static String secret = StripeService.stripesecret;
//   static Map<String, String> headers = {
//     'Authorization': 'Bearer ${StripeService.secret}',
//     'Content-Type': 'application/x-www-form-urlencoded'
//   };
//   static init() {
//     print(stripekey);
//     StripePayment.setOptions(
//       StripeOptions(
//         publishableKey: StripeService.stripekey,
//         merchantId: "Test",
//         androidPayMode: 'test'
//       )
//     );
//   }

//   static Future<StripeTransactionResponse> payWithNewCard({String amount, String currency, String orderId, String customerToken}) async {

//     print(amount);

//     try {
//       var paymentMethod = await StripePayment.paymentRequestWithCardForm(
//         CardFormPaymentRequest()
//       );
//       var paymentIntent = await StripeService.createPaymentIntent(
//         amount,
//         currency
//       );
//       var response = await StripePayment.confirmPaymentIntent(
//         PaymentIntent(
//           clientSecret: paymentIntent['client_secret'],
//           paymentMethodId: paymentMethod.id
//         )
//       );
//       print(response);
//       if (response.status == 'succeeded') {
//         final url = "$api/orders/payment";

//         Map<String, String> body = {
//           'order_id': orderId,
//           'amount': amount,
//           'payment_method': '15',
//           'payment_transaction_id': '',
//         };

//         final response = await http.post(Uri.parse(url), body: body,headers: {HttpHeaders.authorizationHeader: 'Bearer $customerToken'});
//         print(jsonDecode(response.body));
//         return new StripeTransactionResponse(
//           message: 'Transaction successful',
//           success: true
//         );
//       } else {
//         return new StripeTransactionResponse(
//           message: 'Transaction failed',
//           success: false
//         );
//       }
//     } on PlatformException catch(err) {
//       return StripeService.getPlatformExceptionErrorResult(err);
//     } catch (err) {
//       return new StripeTransactionResponse(
//         message: 'Transaction failed: ${err.toString()}',
//         success: false
//       );
//     }
//   }

//   static getPlatformExceptionErrorResult(err) {
//     String message = 'Something went wrong';
//     if (err.code == 'cancelled') {
//       message = 'Transaction cancelled';
//     }

//     return new StripeTransactionResponse(
//       message: message,
//       success: false
//     );
//   }

//   static Future<Map<String, dynamic>> createPaymentIntent(String amount, String currency) async {
//     try {
//       Map<String, dynamic> body = {
//         'amount': amount,
//         'currency': currency,
//         'payment_method_types[]': 'card'
//       };
//       var response = await http.post(
//         Uri.parse(StripeService.paymentApiUrl),
//         body: body,
//         headers: StripeService.headers
//       );
//       print(jsonDecode(response.body));
//       return jsonDecode(response.body);
//     } catch (err) {
//       print('err charging user: ${err.toString()}');
//     }
//     return null;
//   }
// }
