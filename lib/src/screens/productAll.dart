import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:foodexpress/config/api.dart';
import 'package:foodexpress/models/cartmodel.dart';
import 'package:foodexpress/src/Widget/CircularLoadingWidget.dart';
import 'package:foodexpress/src/screens/ProductPage.dart';
import 'package:foodexpress/src/shared/Product.dart';
import 'package:foodexpress/src/shared/colors.dart';
import 'package:provider/provider.dart';
import 'package:foodexpress/providers/auth.dart';
import 'dart:async';
import 'dart:convert';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;


class ProductAllPage extends StatefulWidget {

  final String categoryID;
  final String category;
  final  shop;
  final CartModel model;
  ProductAllPage({Key key, @required this.category,this.categoryID,this.shop, this.model}) : super(key: key);

  @override
  _ProductAllState createState() => _ProductAllState();
}

class _ProductAllState extends State<ProductAllPage> {
  TextEditingController editingProductsController = TextEditingController();
  GlobalKey<RefreshIndicatorState> refreshKey;

  String api = FoodApi.baseApi;
  List<Product> _products = [];
  Future<String> getProducts(String shopID, String categoryID) async {
    final url = "$api/shops/$shopID/categories/$categoryID";
    var response = await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    var resBody = json.decode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        List res = resBody['data'];
        res.forEach((product) {
          _products.add(Product(name: product['name'],in_stock:product['in_stock'],stock_count:product['stock_count'], id: product['id'], imgUrl: product['image'], avgRating: double.tryParse('${product['avgRating']}'),price:double.tryParse('${product['unit_price']}').toDouble(),discount:double.tryParse('${product['discount_price']}').toDouble(),));
        });
      });
    } else {
      throw Exception('Failed to data');
    }
    return "Sucess";
  }
  void SerchProduct(shop,value) async {
    final url = "$api/search/$shop/shops/$value/products";
    var response = await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    var resBody = json.decode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        _products.clear();
        List res = resBody['data'];
        res.forEach((product) {
          _products.add(Product(name: product['name'], in_stock:product['in_stock'],stock_count:product['stock_count'],id: product['id'], imgUrl: product['image'],price:double.tryParse('${product['unit_price']}').toDouble(),discount:double.tryParse('${product['discount_price']}').toDouble(),));
        });
      });

    } else {
      throw Exception('Failed to data');
    }
    return;
  }
  Future<Null> refreshList() async {
    setState(() {
      _products.clear();
      this.getProducts(widget.shop['id'].toString(), widget.categoryID);
    });
  }
  @override
  void initState() {
    super.initState();
    this.getProducts(widget.shop['id'].toString(), widget.categoryID);
  }
  @override
  Widget build(BuildContext context) {
    final currency = Provider.of<AuthProvider>(context).currency;

    return Scaffold(
      backgroundColor: Colors.indigo[50],
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(widget.category),
        actions:
        <Widget>[
          new Padding(
            padding: const EdgeInsets.all(10.0),
            child: new Container(
              height: 150.0,
              width: 30.0,
              child: new GestureDetector(
                onTap: ()  => Navigator.pushNamed(context, '/cart'),
                child: Stack(
                  children: <Widget>[
                    new IconButton(
                        icon: new Icon(
                          Icons.shopping_cart,
                          color: Colors.white,
                        ),
                          onPressed: () => Navigator.pushNamed(context, '/cart'),
                        ),
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
                                    ScopedModel.of<CartModel>(context, rebuildOnChange: true).totalQunty.toString(),
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
      body:
      RefreshIndicator(
      key: refreshKey,
      onRefresh: () async {
          await refreshList();
        },
      child: _products.isEmpty ?  ListView(shrinkWrap: true, children:<Widget>[SizedBox(height: 160.0,),CircularLoadingWidget(height: 200,subtitleText: 'No Products Found',img: 'assets/shopping6.png',)],):
      ListView(
          children: <Widget>[
      Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width/2,
    child:
      GridView.builder(
        shrinkWrap: true,
        primary: false,
        padding: EdgeInsets.all(8.0),
        itemCount: _products.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount( crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 0.8),
        itemBuilder: (context, index){
          return _buildFoodCard(context,currency,_products[index], () {
            Navigator.push(
              context, MaterialPageRoute(builder: (context) {
              return new ProductPage(currency:currency,productData: _products[index],shop: widget.shop,);
            }),
            );
          });
        },
      ),
    )
    ])
    )

    );
  }
}
_buildFoodCard(context,currency,Product food, onTapped) {
  return InkWell(
    highlightColor: Colors.transparent,
    splashColor: Colors.white,
    onTap: onTapped,
    child: Container(
      height: 5000,
      width: MediaQuery.of(context).size.width/10,
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(5)),
          boxShadow: [
            BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.05), offset: Offset(0, 5), blurRadius: 5)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child:
            Container(
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
            food.name != null ? ' '+food.name: '',
            style:  TextStyle(
                color: Colors.black,
                fontSize: 18.0),
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
                        text: ' $currency' + (food.price - food.discount).toString(),
                        style:  TextStyle(
                            fontFamily: 'Montserrat',
                            color: Color(0xFFF75A4C),
                            fontSize: 16.0),
                      ),
                    ])),
                flex: -1,
              ),
              SizedBox(width: 15),
              food.discount !=0?RichText(
                  text: TextSpan(children: [
                    new TextSpan(
                      text: '$currency' + food.discount.toString(),
                      style: new TextStyle(
                        color: Colors.grey,
                        fontSize: 16.0,
                        fontFamily: 'Montserrat',
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ])):Container(),
            ],
          ),
          SizedBox(height: 4),
          // food.avgRating !=0? RatingBar(
          //   initialRating: food.avgRating,
          //   itemSize:20.0,
          //   glowColor: Colors.amberAccent,
          //   minRating: 1,
          //   direction: Axis.horizontal,
          //   allowHalfRating: true,
          //   itemCount: 5,
          //   itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
          //   // itemBuilder: (context, _) => Icon(
          //   //   Icons.star,
          //   //   color: Colors.amber,
          //   // ),
          //   onRatingUpdate: (rating) {
          //     print(rating);
          //   },
          // ):Container(),
          SizedBox(height: 10),
        ],
      ),
    ),
  );
}

