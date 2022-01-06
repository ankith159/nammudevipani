import 'package:foodexpress/src/shared/Product.dart';
import 'package:scoped_model/scoped_model.dart';

class CartModel extends Model {
  List<OrderProduct> cart = [];
  double totalCartValue = 0;
  int totalQunty = 0;
  double deliveryCharge = 0;
  String ShopID = '';
  int get total => cart.length;
  double get Charge =>deliveryCharge;
  String get Sid =>ShopID;
  void addProduct(stock_count,productId,productName,price,qunty, img,variation, options,shop) {
    deliveryCharge = shop['delivery_charge'].toDouble();
    ShopID = shop['id'].toString();
    int index = cart.indexWhere((i) => i.id == productId);
    if (index != -1)
      updateProduct(productId, price,(cart[index].qty+qunty));
    else {
      cart.add(OrderProduct(id: productId,name:productName,price: price,stock_count:stock_count,qty: qunty, imgUrl:img,variation_id: variation,options:options ));
      calculateTotal();
      notifyListeners();
    }
  }

  void removeProduct(product) {
    int index = cart.indexWhere((i) => i.id == product);
    cart[index].qty = 1;
    cart.removeWhere((item) => item.id == product);
    calculateTotal();
    notifyListeners();
  }

  void updateProduct(productId, price, qty) {
    int index = cart.indexWhere((i) => i.id == productId);
    cart[index].qty = qty;
    cart[index].price = price;
    if (cart[index].qty == 0)
     removeProduct(productId);
      calculateTotal();
      notifyListeners();
  }

  void clearCart() {
    cart.forEach((f) => f.qty = 1);
    cart = [];
    deliveryCharge = 0;
    totalQunty = 0;
    notifyListeners();
  }

  void calculateTotal() {
    totalCartValue = 0;
    totalQunty = 0;
    cart.forEach((f) {
      totalCartValue += f.price * f.qty;
      totalQunty += f.qty;
    });
  }

}

