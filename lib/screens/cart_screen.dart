import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/cart_item.dart';
import '../providers/cart.dart' show Cart;
import '../providers/orders.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      "\$${cart.totalAmount.toStringAsFixed(2)}",
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  TextButtonWidget(cart: cart)
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
              child: ListView.builder(
                  itemCount: cart.itemCount(),
                  itemBuilder: (ctx, i) => CartItem(
                      productId: cart.items.keys.toList()[i],
                      id: cart.items.values.toList()[i].id,
                      title: cart.items.values.toList()[i].title,
                      quantity: cart.items.values.toList()[i].quantity,
                      price: cart.items.values.toList()[i].price))),
        ],
      ),
    );
  }
}

class TextButtonWidget extends StatefulWidget {
  const TextButtonWidget({
    Key? key,
    required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  State<TextButtonWidget> createState() => _TextButtonWidgetState();
}

class _TextButtonWidgetState extends State<TextButtonWidget> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: (widget.cart.totalAmount <= 0 || _isLoading)
            ? null
            : () async {
                setState(() {
                  _isLoading = true;
                });
                Provider.of<Orders>(context, listen: false)
                    .addOrder(widget.cart.items.values.toList(),
                        widget.cart.totalAmount)
                    .then((_) {
                  setState(() {
                    _isLoading = false;
                  });
                  widget.cart.clear();
                }).catchError((error) {
                  setState(() {
                    _isLoading = false;
                  });
                });
              },
        child: _isLoading
            ? const CircularProgressIndicator()
            : const Text('ORDER NOW'));
  }
}
