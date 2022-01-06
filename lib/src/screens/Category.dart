import 'dart:ffi';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:foodexpress/config/api.dart';
import 'package:foodexpress/main.dart';
import 'package:foodexpress/models/cartmodel.dart';
import 'package:foodexpress/providers/auth.dart';
import 'package:foodexpress/src/Widget/CircularLoadingWidget.dart';
import 'package:foodexpress/src/screens/cartpage.dart';
import 'package:foodexpress/src/screens/productAll.dart';
import 'package:foodexpress/src/shared/fryo_icons.dart';
import 'package:provider/provider.dart';
import '../shared/styles.dart';
import '../shared/colors.dart';
import './ProductPage.dart';
import '../shared/Product.dart';
import 'dart:async';
import 'dart:convert';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class Category extends StatefulWidget {
  final String shopID;
  final String shopName;
  final CartModel model;
  Category({Key key, @required this.shopID, this.shopName, this.model})
      : super(key: key);

  @override
  _CategoryState createState() => _CategoryState();
}

enum ConfirmAction { CANCEL, ACCEPT }

class _CategoryState extends State<Category> {
  TextEditingController editingProductController = TextEditingController();
  GlobalKey<RefreshIndicatorState> refreshKey;
  String _title;
  String _sitename;
  var authenticated;

  String api = FoodApi.baseApi;
  List _categories = List();
  List _listProduct = List();
  List<Product> _products = [];
  Map<String, dynamic> shop = {
    "id": '',
    "name": '',
    "delivery_charge": 0.0,
    "opening_time": '',
    "closing_time": '',
    "image": '',
    "description": '',
    "address": ''
  };

  Future<String> getCategories(String shopID) async {
    final url = "$api/shops/$shopID/categories";
    var response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    var resBody = json.decode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        _categories = resBody['data']['categories'];
        shop['id'] = resBody['data']['shop']['id'];
        shop['name'] = resBody['data']['shop']['name'];
        shop['description'] = resBody['data']['shop']['description'];
        shop['delivery_charge'] =
            resBody['data']['shop']['delivery_charge'] != null
                ? resBody['data']['shop']['delivery_charge'].toDouble()
                : 0.0;
        shop['opening_time'] = resBody['data']['shop']['opening_time'];
        shop['closing_time'] = resBody['data']['shop']['closing_time'];
        shop['address'] = resBody['data']['shop']['address'];
        shop['image'] = resBody['data']['shop']['image'];
      });
    } else {
      throw Exception('Failed to data');
    }
    return "Sucess";
  }

  Future<String> getProducts(String shopID) async {
    final url = "$api/shops/$shopID/products";
    var response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    var resBody = json.decode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        _listProduct = resBody['data']['products'];
        _listProduct.forEach((element) => _products.add(Product(
            name: element['name'],
            stock_count: element['stock_count'],
            in_stock: element['in_stock'],
            id: element['id'],
            imgUrl: element['image'],
            avgRating: double.tryParse('${element['avgRating']}'),
            price: double.tryParse('${element['unit_price']}').toDouble(),
            discount:
                double.tryParse('${element['discount_price']}').toDouble())));
      });
    } else {
      throw Exception('Failed to');
    }
    return "Sucess";
  }

  void SerchProduct(shop, value) async {
    final url = "$api/search/$shop/shops/$value/products";
    var response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    var resBody = json.decode(response.body);
    print(resBody);
    if (response.statusCode == 200) {
      setState(() {
        _products.clear();
        _listProduct = resBody['data'];
        _listProduct.forEach((element) => _products.add(Product(
              name: element['name'],
              stock_count: element['stock_count'],
              in_stock: element['in_stock'],
              id: element['id'],
              imgUrl: element['image'],
              price: double.tryParse('${element['unit_price']}').toDouble(),
              discount:
                  double.tryParse('${element['discount_price']}').toDouble(),
            )));
      });
    } else {
      throw Exception('Failed to data');
    }
    return;
  }

  Future<Null> refreshList() async {
    setState(() {
      _products.clear();
      _categories.clear();
      this.getCategories(widget.shopID);
      this.getProducts(widget.shopID);
    });
  }

  Future<bool> _onBackPressed() {
    return showDialog(
          context: context,
          barrierDismissible: false, // user must tap button for close dialog!
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Are you sure?'),
              content: const Text(
                  'If you click back, the shop will cancel your order'),
              actions: <Widget>[
                FlatButton(
                  child: const Text('CANCEL'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                FlatButton(
                  child: const Text('ACCEPT'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    ScopedModel.of<CartModel>(context, rebuildOnChange: true)
                        .clearCart();
                  },
                )
              ],
            );
          },
        ) ??
        false;
  }

  @override
  void initState() {
    super.initState();
    this.getCategories(widget.shopID);
    this.getProducts(widget.shopID);
  }

  @override
  Widget build(BuildContext context) {
    final currency = Provider.of<AuthProvider>(context).currency;
    authenticated = Provider.of<AuthProvider>(context).status;
    final token = Provider.of<AuthProvider>(context).token;
    _sitename = Provider.of<AuthProvider>(context).sitename;
    return ScopedModel.of<CartModel>(context, rebuildOnChange: true)
                .totalQunty !=
            0
        ? WillPopScope(
            onWillPop: _onBackPressed,
            child: ScopedModel<CartModel>(
              model: CartModel(),
              child: Scaffold(
                backgroundColor: bgColor,
                appBar: AppBar(
                  centerTitle: true,
                  elevation: 0,
                  backgroundColor: primaryColor,
                  title: Text(shop['name'], textAlign: TextAlign.center),
                  actions: <Widget>[
                    new Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: new Container(
                        height: 150.0,
                        width: 30.0,
                        child: new GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CartPage()));
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
                                      size: 20.0,
                                      color: Colors.orange.shade500),
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
                body: RefreshIndicator(
                  key: refreshKey,
                  onRefresh: () async {
                    await refreshList();
                  },
                  child:
                      storeTab(context, currency, shop, _categories, _products),
                ),
                bottomNavigationBar: CurvedNavigationBar(
                    backgroundColor: Colors.white,
                    color: primaryColor,
                    buttonBackgroundColor: primaryColor,
                    height: 60,
                    animationDuration: Duration(
                      milliseconds: 200,
                    ),
                    items: <Widget>[
                      Icon(Fryo.shop, size: 30, color: Colors.white),
                      Icon(Fryo.cart, size: 30, color: Colors.white),
                      Icon(Fryo.list, size: 30, color: Colors.white),
                      Icon(Fryo.user_1, size: 30, color: Colors.white),
                    ],
                    onTap: _onItemTapped),
              ),
            ))
        : ScopedModel<CartModel>(
            model: CartModel(),
            child: Scaffold(
              backgroundColor: bgColor,
              appBar: AppBar(
                centerTitle: true,
                elevation: 0,
                leading: BackButton(
                  color: white,
                ),
                backgroundColor: primaryColor,
                title: Text(widget.shopName, textAlign: TextAlign.center),
                actions: <Widget>[
                  new Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: new Container(
                      height: 150.0,
                      width: 30.0,
                      child: new GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CartPage()));
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
                bottom: false,
                child: RefreshIndicator(
                  key: refreshKey,
                  onRefresh: () async {
                    await refreshList();
                  },
                  child:
                      storeTab(context, currency, shop, _categories, _products),
                ),
              ),
              bottomNavigationBar: CurvedNavigationBar(
                  backgroundColor: Colors.white,
                  color: primaryColor,
                  buttonBackgroundColor: primaryColor,
                  height: 60,
                  animationDuration: Duration(
                    milliseconds: 200,
                  ),
                  items: <Widget>[
                    Icon(Fryo.shop, size: 30, color: Colors.white),
                    Icon(Fryo.cart, size: 30, color: Colors.white),
                    Icon(Fryo.list, size: 30, color: Colors.white),
                    Icon(Fryo.user_1, size: 30, color: Colors.white),
                  ],
                  onTap: _onItemTapped),
            ),
          );
  }

  Void _onItemTapped(int index) {
    setState(() {
      ScopedModel.of<CartModel>(context, rebuildOnChange: true).clearCart();
      if (index == 1) {
        if (authenticated == Status.Authenticated) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MyHomePage(
                        title: 'My Order',
                        tabsIndex: 1,
                      )));
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else if (index == 2) {
        if (authenticated == Status.Authenticated) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MyHomePage(
                        title: 'Transaction',
                        tabsIndex: 2,
                      )));
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else if (index == 3) {
        if (authenticated == Status.Authenticated) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MyHomePage(
                        title: 'Profile',
                        tabsIndex: 3,
                      )));
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        Navigator.pop(
            context,
            MaterialPageRoute(
                builder: (context) => MyHomePage(
                      title: _sitename,
                      tabsIndex: 0,
                    )));
      }
    });
  }

  int _selectedCategory = 0;
  storeTab(
    BuildContext context,
    currency,
    shop,
    List _categories,
    List<Product> _products,
  ) {
    return ListView(children: <Widget>[
      shop['name'] == ''
          ? Container()
          : Padding(
              padding: EdgeInsets.only(right: 0.0),
              child: Container(
                child: sectionShop(context, currency, shop, onViewMore: () {}),
              ),
            ),
      SizedBox(height: 10.0),
      _categories.isEmpty
          ? Container()
          : Padding(
              padding: EdgeInsets.only(left: 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                      _categories.length,
                      (index) => Padding(
                            padding: EdgeInsets.only(
                                bottom: 30, left: index == 0 ? 10 : 0),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCategory = index;
                                });
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ProductAllPage(
                                      category: _categories[index]['name'],
                                      categoryID:
                                          _categories[index]['id'].toString(),
                                      shop: shop),
                                ));
                              },
                              child: Container(
                                height: 110,
                                width: 90,
                                margin: EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: index == _selectedCategory
                                        ? Color(0xffDC2E45)
                                        : Colors.transparent,
                                    boxShadow: [
                                      BoxShadow(
                                          color: index == _selectedCategory
                                              ? Color.fromRGBO(
                                                  220, 46, 69, 0.31)
                                              : Colors.transparent,
                                          blurRadius: 10,
                                          spreadRadius: 4,
                                          offset: Offset(0.0, 7.0))
                                    ]),
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    CircleAvatar(
                                      radius: 25,
                                      backgroundColor:
                                          index == _selectedCategory
                                              ? Colors.white
                                              : Colors.red.withOpacity(0.1),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        child: Image.network(
                                          _categories[index]['image'],
                                          fit: BoxFit.contain,
                                          height: 35,
                                          width: 35,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      _categories[index]['name'],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: index == _selectedCategory
                                              ? Colors.white
                                              : Colors.black),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )),
                ),
              ),
            ),
      Padding(
        padding: EdgeInsets.only(top: 0.0, left: 15.0, right: 15.0),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(10.0),
                bottomLeft: Radius.circular(10.0),
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              )),
          child: TextField(
            textInputAction: TextInputAction.search,
            onSubmitted: (value) {
              SerchProduct(shop['id'].toString(), value != null ? value : null);
            },
            controller: editingProductController,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              hintText: 'Search for  products',
              hintStyle: TextStyle(fontFamily: 'Montserrat', fontSize: 14.0),
              prefixIcon: Icon(Icons.search, color: Colors.grey),
            ),
          ),
        ),
      ),
      SizedBox(height: 15.0),
      _products.isEmpty
          ? CircularLoadingWidget(
              height: 500,
              subtitleText: 'Products No Found',
              img: 'assets/shopping1.png',
            )
          : Container(
              height: MediaQuery.of(context).size.height / 1.49,
              width: MediaQuery.of(context).size.width / 2,
              child: new GridView.builder(
                  padding:
                      EdgeInsets.only(top: 8, right: 8, left: 8, bottom: 300),
                  shrinkWrap: true,
                  primary: false,
                  // padding: EdgeInsets.all(8.0),
                  itemCount: _products.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 0.8),
                  itemBuilder: (context, index) {
                    return _buildFoodCard(context, currency, _products[index],
                        () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProductPage(
                                  currency: currency,
                                  productData: _products[index],
                                  shop: shop)));
                    });
                  })),
      SizedBox(height: 20.0),
    ]);
  }
}

Widget _buildFoodCard(context, currency, Product food, onTapped) {
  return InkWell(
    highlightColor: Colors.transparent,
    splashColor: Colors.white,
    onTap: onTapped,
    child: Container(
      height: 5000,
      width: MediaQuery.of(context).size.width / 10,
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(5)),
          boxShadow: [
            BoxShadow(
                color: Theme.of(context).focusColor.withOpacity(0.05),
                offset: Offset(0, 5),
                blurRadius: 5)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Container(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: Image.network(
                  food.imgUrl,
                  fit: BoxFit.contain,
                  height: 100,
                  width: double.infinity,
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            food.name != null ? ' ' + food.name : '',
            style: TextStyle(
                color: Color(
                  0xff0E0F19,
                ),
                fontSize: 18,
                fontWeight: FontWeight.w500),
            softWrap: true,
            maxLines: 2,
            overflow: TextOverflow.fade,
          ),
          SizedBox(height: 4),
          Row(
            children: <Widget>[
              Expanded(
                child: RichText(
                    text: TextSpan(children: [
                  new TextSpan(
                    text:
                        ' $currency' + (food.price - food.discount).toString(),
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Color(0xFFF75A4C),
                        fontSize: 14.0),
                  ),
                ])),
                flex: -1,
              ),
              SizedBox(width: 15),
              food.discount != 0
                  ? RichText(
                      text: TextSpan(children: [
                      new TextSpan(
                        text: '$currency' + food.discount.toString(),
                        style: new TextStyle(
                          color: Colors.grey,
                          fontSize: 14.0,
                          fontFamily: 'Montserrat',
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ]))
                  : Container(),
            ],
          ),
          SizedBox(height: 4),
          // food.avgRating !=0?
          // RatingBar(
          //   initialRating: food.avgRating,
          //   itemSize:20.0,
          //   glowColor: Colors.amberAccent,
          //   minRating: 1,
          //   direction: Axis.horizontal,
          //   allowHalfRating: true,
          //   itemCount: 5,
          //   itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
          //   ratingWidget: RatingWidget(full: full, half: half, empty: empty)
          //   // (context, _) => Icon(
          //   //   Icons.star,
          //   //   color: Colors.amber,
          //   // ),
          // ):Container(),
          SizedBox(height: 17),
        ],
      ),
    ),
  );
}

Widget sectionShop(context, currency, shop, {onViewMore}) {
  return Padding(
    padding: EdgeInsets.only(left: 8.0, top: 10.0, right: 8.0),
    child: Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.white,
          ),
          child: Padding(
            padding: EdgeInsets.all(5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Image(
                  image: shop['image'] != null
                      ? NetworkImage(shop['image'])
                      : AssetImage('assets/steak.png'),
                  fit: BoxFit.fitWidth,
                  height: 140.0,
                  width: 900.0,
                ),
                SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 7.0, top: 0.0, right: 7.0),
                  child: Container(
                    child: Text(
                      shop['name'] ?? '',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      softWrap: true,
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(
                            0xff0E0F19,
                          ),
                          fontSize: 15.0),
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 7.0, top: 0.0, right: 7.0),
                  child: Container(
                    child: Text(
                      shop['opening_time'] != null
                          ? 'Shop Time ' +
                              shop['opening_time'] +
                              ' - ' +
                              shop['closing_time']
                          : '',
                      style: TextStyle(fontSize: 13.0),
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0),
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Flexible(
                            child: Icon(
                          Icons.location_on,
                          size: 15.0,
                          color: Colors.amber.shade500,
                        )),
                        Text(
                          shop['address'] != null ? shop['address'] : '',
                          style: TextStyle(fontSize: 13.0),
                          softWrap: false,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 7.0, top: 0.0, right: 7.0),
                  child: Container(
                    child: Text(
                      'Delivery charge ' +
                          ' $currency' +
                          shop['delivery_charge'].toString(),
                      style:
                          TextStyle(color: Color(0xFFF76053), fontSize: 14.0),
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 7.0, top: 0.0, right: 7.0),
                  child: shop['description'] != ''
                      ? Container(
                          child: Text(
                            shop['description'],
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                            softWrap: true,
                            style: TextStyle(fontSize: 12.0),
                          ),
                        )
                      : Container(),
                ),
                SizedBox(height: 5.0),
              ],
            ),
          ),
        )
      ],
    ),
  );
}

Widget sectionHeader(String headerTitle, {onViewMore}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Container(
        margin: EdgeInsets.only(left: 15, top: 10),
        child: Text(headerTitle, style: h4),
      ),
    ],
  );
}
