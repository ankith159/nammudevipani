import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:foodexpress/config/api.dart';
import 'package:foodexpress/providers/auth.dart';
import 'package:foodexpress/src/Widget/CircularLoadingWidget.dart';
import 'package:foodexpress/src/screens/cartpage.dart';
import 'package:foodexpress/src/utils/CustomTextStyle.dart';
import 'package:provider/provider.dart';
import '../shared/Product.dart';
import '../shared/styles.dart';
import '../shared/colors.dart';
import '../shared/buttons.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:foodexpress/models/cartmodel.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GroupModelOptions {
  String id;
  String name;
  String price;
  GroupModelOptions({this.name, this.price, this.id});
}

class GroupModelVariations {
  String id;
  String name;
  String price;
  String discount;
  int stock_count;
  bool in_stock;
  GroupModelVariations(
      {this.name,
      this.price,
      this.discount,
      this.stock_count,
      this.in_stock,
      this.id});
}

class ProductPage extends StatefulWidget {
  final String pageTitle;
  final Product productData;
  final shop;
  final String currency;

  ProductPage(
      {Key key, this.pageTitle, this.currency, this.productData, this.shop})
      : super(key: key);

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  String api = FoodApi.baseApi;
  List _listImage = List();
  List _variations = List();
  List reviews = List();
  List _options = List();
  List Image = [AssetImage('assets/images/icon.png')];

  int _quantity = 1;
  int count = 0;

  String _currOption = '1';
  String _currVariation = '1';

  List<GroupModelVariations> _groupVariations = [];
  List<GroupModelOptions> _groupOptions = [];
  Map<String, dynamic> ProductShow = {
    "id": '',
    "name": '',
    "unit_price": '',
    "discount_price": '',
    "stock_count": '',
    "in_stock": '',
    "description": '',
    "avgRating": '',
    "reviews": '',
  };

  Future<String> getProduct(String shopID, String ProductID) async {
    final url = "$api/shops/$shopID/products/$ProductID";
    var response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    var resBody = json.decode(response.body);
    if (response.statusCode == 200) {
      print(resBody);
      setState(() {
        ProductShow['id'] = resBody['data']['id'];
        ProductShow['name'] = resBody['data']['name'];
        ProductShow['unit_price'] =
            (double.tryParse('${resBody['data']['unit_price']}') -
                    double.tryParse('${resBody['data']['discount_price']}'))
                .toString();
        ProductShow['discount_price'] =
            resBody['data']['discount_price'].toString();
        ProductShow['stock_count'] = resBody['data']['stock_count'];
        ProductShow['in_stock'] = resBody['data']['in_stock'];
        ProductShow['description'] = resBody['data']['description'];
        ProductShow['avgRating'] = resBody['data']['ratings']['avgRating'];
        _listImage = resBody['data']['image'];
        _variations = resBody['data']['variations'];
        reviews = resBody['data']['ratings']['reviews'];
        _options = resBody['data']['options'];
        Image.clear();
        _listImage.forEach((f) => Image.add(NetworkImage(f)));
        _variations
            .forEach((variation) => _groupVariations.add(GroupModelVariations(
                  id: variation['id'].toString(),
                  name: variation['name'],
                  stock_count: int.tryParse('${variation['stock_count']}'),
                  in_stock: variation['in_stock'],
                  price: variation['unit_price'].toString(),
                  discount: variation['discount_price'].toString(),
                )));
        _options.forEach((option) => _groupOptions.add(GroupModelOptions(
              id: option['id'].toString(),
              name: option['name'],
              price: option['unit_price'].toString(),
            )));
      });
    } else {
      throw Exception('Failed to');
    }
    return "Sucess";
  }

  List _selecteCategorys = List();
  List selecteOptions = [];

  void _onCategorySelected(bool selected, category_id, options) {
    if (selected == true) {
      setState(() {
        _selecteCategorys.add(category_id);
        selecteOptions.add(options);
        print(selecteOptions.length);
      });
    } else {
      setState(() {
        selecteOptions.removeWhere((item) => item.id == category_id);
        _selecteCategorys.remove(category_id);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getProduct(
        widget.shop['id'].toString(), (widget.productData.id).toString());
    widget.productData.qty = _quantity;
  }

  @override
  Widget build(BuildContext context) {
    final authenticated = Provider.of<AuthProvider>(context).status;
    final currency = Provider.of<AuthProvider>(context).currency;

    void _showToast(BuildContext context) {
      final scaffold = Scaffold.of(context);
      scaffold.showSnackBar(
        SnackBar(
          content: const Text('Added to cart'),
          action: SnackBarAction(
              label: 'Dismiss', onPressed: scaffold.hideCurrentSnackBar),
        ),
      );
    }

    Future<void> _showAlert(BuildContext context) {
      return showDialog<void>(
        context: context,
        useRootNavigator: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Product Stock Out'),
            actions: <Widget>[
              FlatButton(
                child: Text('Dismiss'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    Widget imageCarousel = Container(
      height: 300.0,
      child: Carousel(
        boxFit: BoxFit.cover,
        images: [NetworkImage(widget.productData.imgUrl)],
        autoplay: false,
        animationCurve: Curves.fastOutSlowIn,
        animationDuration: Duration(milliseconds: 1000),
        dotSize: 4.0,
        indicatorBgPadding: 8.0,
        dotColor: Colors.red,
      ),
    );
    return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: primaryColor,
          centerTitle: true,
          leading: BackButton(
            color: Colors.white,
          ),
          title: Text(
            widget.productData.name,
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            new Padding(
              padding: const EdgeInsets.all(10.0),
              child: new Container(
                height: 150.0,
                width: 30.0,
                child: new GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => CartPage()));
                  },
                  child: Stack(
                    children: <Widget>[
                      new IconButton(
                          icon: new Icon(
                            Icons.shopping_cart,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CartPage()));
                          }),
                      new Positioned(
                          child: new Stack(
                        children: <Widget>[
                          new Icon(Icons.brightness_1,
                              size: 20.0, color: Colors.orange.shade500),
                          new Positioned(
                              top: 4.0,
                              right: 5.5,
                              child: new Center(
                                child: new Text(
                                  ScopedModel.of<CartModel>(context,
                                          rebuildOnChange: true)
                                      .totalQunty
                                      .toString(),
                                  style: new TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.0,
                                      fontWeight: FontWeight.w500),
                                ),
                              )),
                        ],
                      )),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
        body: SafeArea(
            child: ProductShow['name'] == ''
                ? ListView(
                    children: <Widget>[
                      SizedBox(
                        height: 70,
                      ),
                      CircularLoadingWidget(
                        height: 500,
                        subtitleText: 'No product found',
                        img: 'assets/shopping1.png',
                      )
                    ],
                  )
                : ScopedModelDescendant<CartModel>(
                    builder: (context, child, model) {
                    return Column(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                              child: ListView(children: <Widget>[
                            imageCarousel,
                            Padding(
                              padding: const EdgeInsets.only(
                                  right: 20, left: 20, bottom: 10, top: 25),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      ProductShow['name'],
                                      overflow: TextOverflow.fade,
                                      softWrap: true,
                                      maxLines: 2,
                                      style: CustomTextStyle.textFormFieldMedium
                                          .copyWith(
                                              color: Colors.black54,
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  right: 20, left: 20, bottom: 10, top: 5),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      'Price ' +
                                          currency +
                                          ProductShow['unit_price'].toString(),
                                      overflow: TextOverflow.fade,
                                      softWrap: true,
                                      maxLines: 2,
                                      style: CustomTextStyle.textFormFieldMedium
                                          .copyWith(
                                              color: Colors.amberAccent,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // reviews.isEmpty
                            //     ? Container()
                            //     : Padding(
                            //         padding: const EdgeInsets.symmetric(
                            //             horizontal: 10, vertical: 0),
                            //         child: RatingBar(
                            //           initialRating: ProductShow['avgRating'] !=
                            //                   ''
                            //               ? double.tryParse(
                            //                       '${ProductShow['avgRating']}')
                            //                   .toDouble()
                            //               : 0,
                            //           itemSize: 25.0,
                            //           glowColor: Colors.amberAccent,
                            //           minRating: 1,
                            //           direction: Axis.horizontal,
                            //           allowHalfRating: true,
                            //           itemCount: 5,
                            //           itemPadding:
                            //               EdgeInsets.symmetric(horizontal: 4.0),
                            //           //  itemBuilder: (context, _) => Icon(
                            //           //    Icons.star,
                            //           //    color: Colors.amber,
                            //           //  ),
                            //         ),
                            //       ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 5),
                              child: Text(
                                ProductShow['description'] != null
                                    ? ProductShow['description']
                                    : '',
                                overflow: TextOverflow.fade,
                                style: CustomTextStyle.textFormFieldMedium
                                    .copyWith(
                                        color: Colors.black54,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                              ),
                            ),
                            _groupVariations.isEmpty
                                ? Container()
                                : Column(children: <Widget>[
                                    Container(
                                      child: ListTile(
                                        title: Text(
                                          'Variation',
                                          overflow: TextOverflow.fade,
                                          softWrap: true,
                                          maxLines: 2,
                                          style: CustomTextStyle
                                              .textFormFieldMedium
                                              .copyWith(
                                                  color: Colors.black,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    Container(
                                        child: Container(
                                      child: Column(
                                        children: _groupVariations
                                            .map((t) => t.in_stock == true
                                                ? RadioListTile(
                                                    value: t.id,
                                                    groupValue: _currVariation,
                                                    title: Text(
                                                      "${t.name}",
                                                      overflow:
                                                          TextOverflow.fade,
                                                      softWrap: true,
                                                      maxLines: 1,
                                                      style: CustomTextStyle
                                                          .textFormFieldMedium
                                                          .copyWith(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                    ),
                                                    onChanged: (val) {
                                                      setState(() {
                                                        _currVariation = val;
                                                        ProductShow[
                                                            'unit_price'] = (double
                                                                    .tryParse(
                                                                        '${t.price}') -
                                                                double.tryParse(
                                                                    '${t.discount}'))
                                                            .toString();
                                                        ProductShow[
                                                                'stock_count'] =
                                                            t.stock_count;
                                                        ProductShow[
                                                                'in_stock'] =
                                                            t.in_stock;
                                                        int index = model.cart
                                                            .indexWhere((i) =>
                                                                i.id ==
                                                                ProductShow[
                                                                    'id']);
                                                        if (index != -1) {
                                                          model.removeProduct(
                                                              model.cart[index]
                                                                  .id);
                                                        }
                                                      });
                                                    },
                                                    activeColor: Colors.red,
                                                    secondary: OutlineButton(
                                                      child: Text(currency +
                                                          (double.tryParse(
                                                                      '${t.price}') -
                                                                  double.tryParse(
                                                                      '${t.discount}'))
                                                              .toString()),
                                                      onPressed: () {},
                                                    ),
                                                  )
                                                : Container())
                                            .toList(),
                                      ),
                                    )),
                                  ]),
                            _groupVariations.isEmpty
                                ? Container()
                                : SizedBox(
                                    height: 5,
                                  ),
                            _groupOptions.isEmpty
                                ? Container()
                                : Column(
                                    children: <Widget>[
                                      Container(
                                        child: ListTile(
                                          title: Text(
                                            'Options',
                                            overflow: TextOverflow.fade,
                                            softWrap: true,
                                            maxLines: 2,
                                            style: CustomTextStyle
                                                .textFormFieldMedium
                                                .copyWith(
                                                    color: Colors.black,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 15,
                                          ),
                                          child: Container(
                                            child: ListView.builder(
                                                shrinkWrap: true,
                                                primary: false,
                                                itemCount: _groupOptions.length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return CheckboxListTile(
                                                    title: Text(
                                                      _groupOptions[index].name,
                                                      overflow:
                                                          TextOverflow.fade,
                                                      softWrap: true,
                                                      maxLines: 2,
                                                      style: CustomTextStyle
                                                          .textFormFieldMedium
                                                          .copyWith(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                    ),
                                                    subtitle: Text(
                                                      '\$' +
                                                          _groupOptions[index]
                                                              .price,
                                                      overflow:
                                                          TextOverflow.fade,
                                                      softWrap: true,
                                                      maxLines: 2,
                                                      style: CustomTextStyle
                                                          .textFormFieldMedium
                                                          .copyWith(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                    ),
                                                    value: _selecteCategorys
                                                        .contains(
                                                            _groupOptions[index]
                                                                .id),
                                                    onChanged: (bool selected) {
                                                      _onCategorySelected(
                                                          selected,
                                                          _groupOptions[index]
                                                              .id,
                                                          _groupOptions[index]);
                                                    },
                                                  );
                                                }),
                                          )),
                                    ],
                                  ),
                            Divider(),
                            reviews.isEmpty
                                ? Container()
                                : Padding(
                                    padding: const EdgeInsets.only(
                                        left: 15.0, bottom: 16.0),
                                    child: Align(
                                        alignment: Alignment(-1, 0),
                                        child: Text(
                                          'Recent Reviews',
                                          style: CustomTextStyle
                                              .textFormFieldMedium
                                              .copyWith(
                                                  color: Colors.black,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                        )),
                                  ),
                            reviews.isEmpty
                                ? Container()
                                : Column(
                                    children:
                                        List.generate(reviews.length, (index) {
                                      return reviews[index]['status'] == 5
                                          ? Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4.0),
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              5.0))),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 16.0),
                                                    child: CircleAvatar(
                                                      maxRadius: 14,
                                                      backgroundImage:
                                                          NetworkImage(
                                                              reviews[index]
                                                                  ['image']),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: <Widget>[
                                                            Text(
                                                              reviews[index]
                                                                      ['name']
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            Text(
                                                              reviews[index]
                                                                      ['date']
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize:
                                                                      10.0),
                                                            )
                                                          ],
                                                        ),
                                                        // Padding(
                                                        //   padding:
                                                        //       const EdgeInsets
                                                        //               .symmetric(
                                                        //           vertical:
                                                        //               8.0),
                                                        //   child: RatingBar(
                                                        //     initialRating:
                                                        //         double.tryParse(
                                                        //                 '${reviews[index]['rating']}')
                                                        //             .toDouble(),
                                                        //     itemSize: 20.0,
                                                        //     glowColor: Colors
                                                        //         .amberAccent,
                                                        //     minRating: 1,
                                                        //     direction:
                                                        //         Axis.horizontal,
                                                        //     allowHalfRating:
                                                        //         true,
                                                        //     itemCount: 5,
                                                        //     itemPadding: EdgeInsets
                                                        //         .symmetric(
                                                        //             horizontal:
                                                        //                 4.0),
                                                        //     // itemBuilder: (context, _) => Icon(
                                                        //     //   Icons.star,
                                                        //     //   color: Colors.amber,
                                                        //     // ),
                                                        //   ),
                                                        // ),
                                                        Text(
                                                          reviews[index]
                                                                  ['review']
                                                              .toString(),
                                                          style: TextStyle(
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ))
                                          : Container();
                                    }),
                                  )
                          ])),
                          flex: 90,
                        ),
                        Expanded(
                          child: Container(
                              width: double.infinity,
                              margin: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 0),
                              child: widget.productData.in_stock == false
                                  ? Container()
                                  : Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                            width: 55,
                                            height: 40,
                                            child: OutlineButton(
                                              onPressed: () {
                                                setState(() {
                                                  if (ProductShow['in_stock']) {
                                                    if (_quantity == 1) return;
                                                    _quantity -= 1;
                                                  }
                                                });
                                              },
                                              child: Icon(Icons.remove),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(
                                                left: 20, right: 20),
                                            child: Text(_quantity.toString(),
                                                style: h3),
                                          ),
                                          Container(
                                            width: 55,
                                            height: 40,
                                            child: OutlineButton(
                                              onPressed: () {
                                                int index = model.cart
                                                    .indexWhere((i) =>
                                                        i.id ==
                                                        ProductShow['id']);
                                                var value = 0;
                                                if (index != -1) {
                                                  if (ProductShow[
                                                          'unit_price'] !=
                                                      '1')
                                                    value =
                                                        (model.cart[index].qty +
                                                            _quantity);
                                                } else {
                                                  value = _quantity;
                                                }
                                                setState(() {
                                                  if (ProductShow['in_stock']) {
                                                    if (ProductShow[
                                                                'stock_count'] >=
                                                            value &&
                                                        (ProductShow[
                                                                    'stock_count'] -
                                                                value) !=
                                                            0) {
                                                      if (double.parse(
                                                              ProductShow[
                                                                  'unit_price']) >
                                                          1) _quantity += 1;
                                                    } else {
                                                      _showAlert(context);
                                                    }
                                                  }
                                                });
                                              },
                                              child: Icon(Icons.add),
                                            ),
                                          ),
                                          Container(
                                            width: 130,
                                            height: 45,
                                            margin: EdgeInsets.only(
                                              left: 15,
                                            ),
                                            child:
                                                froyoFlatBtn('Add to Cart', () {
                                              int index = model.cart.indexWhere(
                                                  (i) =>
                                                      i.id ==
                                                      ProductShow['id']);
                                              var value = 0;
                                              if (index != -1) {
                                                if (double.parse(ProductShow[
                                                        'unit_price']) >
                                                    1)
                                                  value =
                                                      (model.cart[index].qty +
                                                          _quantity);
                                              } else {
                                                value = _quantity;
                                              }

                                              if (ProductShow['stock_count'] >=
                                                  value) {
                                                double total = 0;
                                                selecteOptions.forEach(
                                                    (element) => total =
                                                        (total +
                                                            double.parse(element
                                                                .price)));
                                                model.addProduct(
                                                    ProductShow['stock_count'],
                                                    ProductShow['id'],
                                                    ProductShow['name'],
                                                    (total +
                                                            double.parse(
                                                                ProductShow[
                                                                    'unit_price']))
                                                        .toDouble(),
                                                    _quantity,
                                                    widget.productData.imgUrl,
                                                    _currVariation,
                                                    selecteOptions,
                                                    widget.shop);
                                                _quantity = 1;
                                              } else {
                                                _showAlert(context);
                                              }
                                            }),
                                          ),
                                        ],
                                      ),
                                    )),
                          flex: 10,
                        )
                      ],
                    );
                  })));
  }
}
