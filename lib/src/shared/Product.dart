class Product {
  int id;
  String name;
  String imgUrl;
  double price;
  double discount;
  int qty;
  double avgRating;
  int stock_count;
  bool in_stock;


  Product({this.id, this.name,this.in_stock,this.stock_count,this.avgRating, this.price,this.discount, this.qty, this.imgUrl,});
}

class OrderProduct {
  int id;
  String name;
  double price;
  int qty;
  String imgUrl;
  int stock_count;
  String variation_id;
  bool in_stock;
  List options =[];


  OrderProduct({this.id, this.name,this.in_stock,this.stock_count, this.price, this.qty,this.imgUrl,this.options,this.variation_id});
}

class ItemProduct {
  String shop_id;
  int product_id;
  double discounted_price;
  double unit_price;
  int quantity;
  String shop_product_variation_id;
  List options =[];

  ItemProduct({this.shop_id, this.product_id, this.unit_price, this.quantity, this.discounted_price,this.shop_product_variation_id,this.options});

  Map<String, dynamic> TojsonData() {
    var map = new Map<String, dynamic>();
    map["shop_id"] = shop_id;
    map["shop_product_variation_id"] = shop_product_variation_id;
    map["product_id"] = product_id;
    map["unit_price"] = unit_price;
    map["quantity"] = quantity;
    map["discounted_price"] = discounted_price;
    map["options"] = options;
    return map;
  }
}

class Options {
  String id;
  String name;
  String price;
  Options({this.id,this.name, this.price});
  Map<String, dynamic> TojsonData() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["name"] = name;
    map["price"] = price;
    return map;
  }
}
