import 'package:flutter/material.dart';


class OrderItemWidget extends StatelessWidget {
  final  product;
  final String currency;
  const OrderItemWidget({Key key, this.currency,this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).accentColor,
      focusColor: Theme.of(context).accentColor,
      highlightColor: Theme.of(context).primaryColor,
      onTap: () {
//        Navigator.of(context).pushNamed('/Tracking', arguments: RouteArgument(id: order.id, heroTag: this.heroTag));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.1), blurRadius: 5, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Hero(
              tag: 'heroTag'+ product['product_id'].toString(),
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  image: DecorationImage(image: NetworkImage(product['product']['image']), fit: BoxFit.cover),
                ),
              ),
            ),
            SizedBox(width: 15),
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          product['product']['name'],
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        product['variation'] == null?Container(): Column(
                          children: <Widget>[
                            Text(
                              '- '+product['variation']['name'] +' ( $currency${product['variation']['price']} )',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: Theme.of(context).textTheme.caption,
                            ),
                          ],
                        ),
                        product['options'].length == 0 ? Container(): Column(
                          children: List.generate(product['options'].length,(index){
                            return Text(
                              '-- '+product['options'][index]['name'] + ' ( $currency${product['options'][index]['price']} )',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: Theme.of(context).textTheme.caption,
                            );
                          }),
                        ),
                        Text(
                          product['shop']['name'],
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.caption,
                        ),
                        Text(
                          '( ' + product['quantity'].toString() +' x '+ '$currency'+product['unit_price'].toString() + ' ) ' + '= ' + '$currency'+product['item_total'].toString(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                          product['updated_at'] !=null ? product['updated_at']:'',
                        style: Theme.of(context).textTheme.caption,
                      ),
                      Text(
                        'Total  '+'$currency'+product['item_total'].toString(),
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
