import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:foodexpress/providers/auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class SellPage extends StatefulWidget {
  const SellPage();

  @override
  _SellPageState createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  @override
  initState() {
    super.initState();
    getItems();
  }

  TextEditingController name = TextEditingController();
  TextEditingController quantity = TextEditingController();
  TextEditingController type = TextEditingController();

  Map products = {};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: Text('Sell Products'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: name,
                        decoration: InputDecoration(hintText: 'Name'),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: quantity,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(hintText: 'Quantity'),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: type,
                        decoration: InputDecoration(hintText: 'Product type'),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                              onPressed: () async {
                                if (name.text.isNotEmpty &&
                                    quantity.text.isNotEmpty &&
                                    type.text.isNotEmpty) {
                                  var _pick = ImagePicker();
                                  var file = await _pick.pickImage(
                                      source: ImageSource.gallery);
                                  if (file == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text('Select Image')));
                                    return;
                                  }
                                  if (file.path == null || file.path.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text('Select Image')));
                                    return;
                                  }
                                  if (file != null) {
                                    var apiUrl =
                                        'https://nammudevipani.com/app/subscription/get-sell-product-content';
                                    var req = http.MultipartRequest(
                                        'POST', Uri.parse(apiUrl));
                                    req.files.add(
                                        await http.MultipartFile.fromPath(
                                            'product_image', file.path));
                                    // req.fields['product_name']= 'name';
                                    req.fields.addAll({
                                      'product_name': name.text,
                                      'quantity': quantity.text,
                                      'product_type': type.text,
                                      'customers_mobile': '',
                                      'area_id': '2',
                                      'customers_id': '',
                                      'zone': '',
                                      'CL_latitude': '',
                                      'CL_longitude': '',
                                      'building': '',
                                      'scheduled_date': '',
                                      'time_slot_id': '1',
                                      'order_comments': '',
                                      'delivery_charge': '1',
                                      'street': ''
                                    });
                                    req.headers.addAll({
                                      HttpHeaders.acceptHeader:
                                          "application/json",
                                      HttpHeaders.authorizationHeader:
                                          'Bearer ${Provider.of<AuthProvider>(context, listen: false).token}'
                                    });
                                    var resp = await req.send();
                                    print(resp.statusCode);
                                    if (resp.statusCode == 200) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text('Product added')));
                                      Navigator.pop(context);
                                    }
                                  }
                                }
                              },
                              child: Text('Done'))
                        ],
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(children: [
                    Html(
                        data: products['sell_product_content']['desription']
                            .toString())
                  ]
                      //      List.generate(
                      //   1,
                      //   (index) => Text(
                      //     products['sell_product_content']['desription'].toString(),
                      //   ),
                      // )
                      ),
                ),
              ],
            ),
          ),
        ));
  }

  getItems() async {
    print(Provider.of<AuthProvider>(context, listen: false).token);
    final response = await http.get(
        Uri.parse(
            'https://nammudevipani.com/app/subscription/get-sell-product-content'),
        headers: {
          HttpHeaders.acceptHeader: "application/json",
          HttpHeaders.authorizationHeader:
              'Bearer ${Provider.of<AuthProvider>(context, listen: false).token}'
        });
    print(response.statusCode);
    print(response.body);
    var pro = jsonDecode(response.body);
    setState(() {
      products = pro;
    });
  }
}
