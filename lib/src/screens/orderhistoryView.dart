
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:foodexpress/config/api.dart';
import 'package:foodexpress/src/Widget/CircularLoadingWidget.dart';
import 'package:foodexpress/src/Widget/OrderItemWidget.dart';
import 'package:foodexpress/src/screens/paymentType.dart';
import 'package:foodexpress/src/shared/colors.dart';
import 'package:foodexpress/src/utils/CustomTextStyle.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:foodexpress/providers/auth.dart';

class OrderViewPage extends StatefulWidget {
  final String orderID;
  final String currency;
  OrderViewPage({Key key, this.orderID,this.currency}) : super(key: key);

  @override
  _OrderHistoryViewPageState createState() {
    return new _OrderHistoryViewPageState();
  }
}

class _OrderHistoryViewPageState extends State<OrderViewPage> {
  GlobalKey<RefreshIndicatorState> refreshKey;
  String api = FoodApi.baseApi;
  final rows = <TableRow>[];
   int statusValue =0;
  Map<String, dynamic> orderView = {"totalAmount":'',"sub_total":'',"delivery_charge":'',"orderId":'',"amount":'',"status_name" :'',"status": '',"payment_method":'',"payment_status":'', "oderCode" :'',"Items":[]};

  Future<String> getmyOrder(orderID,token) async {
    final url = "$api/orders/$orderID/show";
    print(url);
    var response = await http.get(Uri.parse(url),headers: {HttpHeaders.authorizationHeader: 'Bearer $token',HttpHeaders.contentTypeHeader: "application/json; charset=utf-8"});
    var resBody = json.decode(response.body);
    if (response.statusCode == 200) {
      var order = json.decode(resBody['data']['misc']);
      print(resBody);
      setState(() {
        orderView['totalAmount'] = resBody['data']['total'];
        orderView['sub_total'] = resBody['data']['sub_total'];
        orderView['delivery_charge'] = resBody['data']['delivery_charge'];
        orderView['status_name'] = resBody['data']['status_name'];
        orderView['orderId'] = resBody['data']['id'].toString();
        orderView['amount'] = resBody['data']['total'].toString();
        orderView['payment_method'] = resBody['data']['payment_method'].toString();
        orderView['payment_status'] = resBody['data']['payment_status'].toString();
        orderView['status'] = resBody['data']['status'].toString();
        orderView['Items'] = resBody['data']['items'];
        orderView['oderCode'] = order['order_code'];
        if(orderView['status'] == '5'){
          statusValue = 0;
        }else if(int.tryParse(orderView['status']) == int.tryParse('14')){
          statusValue = 1;
        }else if(int.tryParse(orderView['status']) == int.tryParse('15')){
          statusValue = 2;
        }else if(int.tryParse(orderView['status']) == int.tryParse('17')){
          statusValue = 3;
        }else if(int.tryParse(orderView['status']) == int.tryParse('20')){
          statusValue = 4;
        }

      });
    } else {
      throw Exception('Failed to data');
    }
    return "Sucess";
  }
  Future<Null> refreshList() async {
    final _token = Provider.of<AuthProvider>(context,listen: false).token;
    setState(() {
      orderView['Items'] = [];
      this.getmyOrder(widget.orderID,_token);
    });
  }
  double iconSize = 40;

  @override
  void initState() {
    super.initState();
    final _token = Provider.of<AuthProvider>(context,listen: false).token;
    this.getmyOrder(widget.orderID,_token);
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);

    return Scaffold(
        backgroundColor: Color(0xffF4F7FA),
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: primaryColor,
          title:
          Text('Order view', textAlign: TextAlign.center),
        ),
      body:
      RefreshIndicator(
        key: refreshKey,
        onRefresh: () async {
        await refreshList();
        },
        child: orderView['Items'].length ==0  ? ListView(children:<Widget>[CircularLoadingWidget(height: 400,subtitleText: 'No Orders found',img: 'assets/shopping5.png')],):
        Builder(builder: (context) {
          return Column(
            children: <Widget>[
              Expanded(
                child:
                Container(
                  child:
                  ListView(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    children: <Widget>[
                      Theme(
                        data: theme,
                        child: ExpansionTile(
                          initiallyExpanded: true,
                          title: Row(
                            children: <Widget>[
                              Expanded(child: Text(orderView['oderCode']!=null ? orderView['oderCode']:'')),
                              Text(
                                orderView['status_name']!=null ? orderView['status_name']:'',
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ],
                          ),
                          children: List.generate(orderView['Items'].length, (index) {
                            return OrderItemWidget(currency:widget.currency,product:orderView['Items'][index]);
                          }),
                        ),
                      ),
                      SizedBox(height: 10),
                      Card(
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
                              createPriceItem("Order Total",widget.currency, orderView['sub_total'],
                                  Colors.grey.shade700),
                              createPriceItem(
                                  "Delivery Charges",widget.currency, orderView['delivery_charge'], Colors.teal.shade300),
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
                                  Text(
                                    "Total",
                                    style: CustomTextStyle.textFormFieldSemiBold
                                        .copyWith(color: Colors.black, fontSize: 12),
                                  ),
                                  Text(
                                    "${widget.currency}"+orderView['totalAmount'],
                                    style: CustomTextStyle.textFormFieldMedium
                                        .copyWith(color: Colors.black, fontSize: 12),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Theme(
                        data: ThemeData(
                          primaryColor: Theme.of(context).accentColor,
                        ),
                        child: Stepper(
                          physics : ClampingScrollPhysics(),
                          controlsBuilder: (BuildContext context,
                              {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
                            return SizedBox(height: 0.0);
                          },
                          steps: getTrackingSteps(context,orderView['status_name'],orderView['status']),
                          currentStep: statusValue,
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                          padding: EdgeInsets.fromLTRB(15, 4, 4, 8),
                          child: Text(
                            'Payment details',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: primaryColor),
                          )
                      ),
                      Padding(
                          padding: EdgeInsets.fromLTRB(15, 4, 4, 8),
                          child: orderView['payment_status'] == '5' ?
                          Text('Payment status - Paid',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ):Text('Payment status - Unpaid',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          )
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
                flex: 95,
              ),
              Expanded(
                child: orderView['payment_status'] == '5' ? Container():
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: RaisedButton(
                    onPressed: () {
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) => PaymentMethodsPage(amount: orderView['amount'],orderID: orderView['orderId'],)));
                    },
                    child: Text(
                      "Pay Now",
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
      )
    );

  }
  List<Step> getTrackingSteps(BuildContext context,statusName,status) {
    List<Step> _orderStatusSteps = [];
    if(status == '10'){
      _orderStatusSteps.add(Step(
        state: StepState.complete,
        title: Text(
          'Order Cancel',
          style: Theme.of(context).textTheme.subtitle1,
        ),
        content: SizedBox(
            width: double.infinity,
            child: Text(
              '',
            )),
        isActive: (int.tryParse(status)) >= (int.tryParse('10')),
      ));
    }else {
      _orderStatusSteps.add(Step(
        state: StepState.complete,
        title: Text(
          'Order Pending',
          style: Theme.of(context).textTheme.subtitle1,
        ),
        content: SizedBox(
            width: double.infinity,
            child: Text(
              '',
              style: TextStyle(color: Colors.green,fontSize: 16,fontWeight: FontWeight.bold),
            )),
        isActive: (int.tryParse(status)) >= (int.tryParse('5')),
      ));
    }
    if(status == '12'){
      _orderStatusSteps.add(Step(
        state: StepState.complete,
        title: Text(
          'Order Reject',
          style: Theme.of(context).textTheme.subtitle1,
        ),
        content: SizedBox(
            width: double.infinity,
            child: Text(
              '',
            )),
        isActive: (int.tryParse(status)) >= (int.tryParse('12')),
      ));
    }else {
      _orderStatusSteps.add(Step(
        state: StepState.complete,
        title: Text(
          'Order Accept',
          style: Theme.of(context).textTheme.subtitle1,
        ),
        content: SizedBox(
            width: double.infinity,
            child: Text(
              '',
              style: TextStyle(color: Colors.green,fontSize: 16,fontWeight: FontWeight.bold),
            )),
        isActive: (int.tryParse(status)) >= (int.tryParse('14')),
      ));
    }
    _orderStatusSteps.add(Step(
      state: StepState.complete,
      title: Text(
        'Order Process ',
        style: Theme.of(context).textTheme.subtitle1,
      ),
      content: SizedBox(
          width: double.infinity,
          child: Text(
            '',
            style: TextStyle(color: Colors.green,fontSize: 16,fontWeight: FontWeight.bold),
          )),
      isActive: (int.tryParse(status)) >= (int.tryParse('15')),
    ));
    _orderStatusSteps.add(Step(
      state: StepState.complete,
      title: Text(
        'On The Way',
        style: Theme.of(context).textTheme.subtitle1,
      ),
      content: SizedBox(
          width: double.infinity,
          child: Text(
            '',
            style: TextStyle(color: Colors.green,fontSize: 16,fontWeight: FontWeight.bold),
          )),
      isActive: (int.tryParse(status)) >= (int.tryParse('17')),
    ));
    _orderStatusSteps.add(Step(
      state: StepState.complete,
      title: Text(
        'Order Completed',
        style: Theme.of(context).textTheme.subtitle1,
      ),
      content: SizedBox(
          width: double.infinity,
          child: Text(
            '',
            style: TextStyle(color: Colors.green,fontSize: 16,fontWeight: FontWeight.bold),
          )),
      isActive: (int.tryParse(status)) >= (int.tryParse('20')),
    ));
    return _orderStatusSteps;
  }

  createPriceItem(String key,String currency, String value, Color color) {
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
            '$currency'+value,
            style: CustomTextStyle.textFormFieldMedium
                .copyWith(color: color, fontSize: 12),
          )
        ],
      ),
    );
  }

}
