import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem(
      {required this.id,
      required this.amount,
      required this.products,
      required this.dateTime});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  String authToken = '';
  String userId = '';
  Orders(this.userId, this.authToken, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> FetchAndSetOrders() async {
    try {
      final url = Uri.parse(
          'https://shop-app-flutter-71a7e-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
      final response = await http.get(url);
      if (json.decode(response.body) == null) {
        return;
      }
      final loadedOrders = json.decode(response.body) as Map<String, dynamic>;
      final List<OrderItem> orders = [];
      loadedOrders.forEach((orderId, orderData) {
        orders.add(OrderItem(
            id: orderId,
            amount: orderData['total'],
            products: (orderData['cartProducts'] as List<dynamic>)
                .map((cp) => CartItem(
                    id: cp['id'],
                    title: cp['title'],
                    quantity: cp['quantity'],
                    price: cp['price']))
                .toList(),
            dateTime: DateTime.parse(orderData['dateTime'])));
      });
      _orders = orders.reversed.toList();
      notifyListeners();
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(
        'https://shop-app-flutter-71a7e-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    try {
      final time = DateTime.now();
      final response = await http.post(url,
          body: json.encode({
            'cartProducts': cartProducts
                .map((cp) => {
                      'id': cp.id,
                      'title': cp.title,
                      'quantity': cp.quantity,
                      'price': cp.price,
                    })
                .toList(),
            'total': total,
            'dateTime': time.toIso8601String(),
          }));

      _orders.insert(
          0,
          OrderItem(
              id: json.decode(response.body)["name"],
              amount: total,
              products: cartProducts,
              dateTime: time));
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }
}
