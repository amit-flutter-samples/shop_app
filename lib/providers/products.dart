import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';

import './product.dart';

class Products with ChangeNotifier {
  static const ROOT_URL = 'https://flutter-shop-app-dbc34.firebaseio.com/';
  final String auth;
  final String userId;

  Products(this.auth, this.userId, this._items);

  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((item) => item.isFavorite).toList();
  }

  Future<dynamic> _getFavProducts() async {
    final favUrl = ROOT_URL + 'userFavorites/$userId.json?auth=$auth';
    final response = await http.get(favUrl);
    final favData = json.decode(response.body);
    return favData;
  }

  Future<void> getProducts([bool filterByUser = false]) async {
    final filterParam = filterByUser ? '&orderBy="createdBy"&equalTo="$userId"' : '';
    final productUrl = ROOT_URL + 'products.json?auth=$auth$filterParam';
    try {
      var response = await http.get(productUrl);
      final data = json.decode(response.body) as Map<String, dynamic>;

      _items.length = 0;
      if(data == null) {
        return;
      }

      var favData = await _getFavProducts();

      data.forEach((prodId, prodData) {
        _items.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          imageUrl: prodData['imageUrl'],
          isFavorite: favData == null ? false : favData[prodId] ?? false,
        ));
      });
      notifyListeners();
    } catch (error) {}
  }

  Future<void> addProduct(Product product) async {
    final productUrl = ROOT_URL + 'products.json?auth=$auth';
    try {
      final response = await http.post(
        productUrl,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'createdBy': userId,
        }),
      );

      final newProduct = Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);
      _items.insert(0, newProduct);
    } catch (error) {
      throw (error);
    }
  }

  Future<void> updateProduct(String id, Product product) async {
    final productIndex = _items.indexWhere((prod) => prod.id == product.id);
    if (productIndex >= 0) {
      final productUrl = ROOT_URL + 'products/$id.json?auth=$auth';
      try {
        var response = await http.patch(productUrl,
            body: json.encode({
              'title': product.title,
              'description': product.description,
              'imageUrl': product.imageUrl,
              'price': product.price
            }));
        if(response.statusCode >= 400) {
          throw HttpException('Update item failed');
        }
        _items[productIndex] = product;
        notifyListeners();
      } catch (error) {
        throw (error);
      }
    }
  }

  Future<void> deleteProduct(String productId) async {
    final productUrl = ROOT_URL + 'products/$productId.json?auth=$auth';
    final existingProductIndex =
        _items.indexWhere((item) => item.id == productId);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(productUrl);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Item can not be deleted.');
    }
    existingProduct = null;
  }

  Product findById(String id) {
    return _items.firstWhere((item) => item.id == id);
  }
}
