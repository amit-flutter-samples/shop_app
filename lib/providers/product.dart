import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  static const ROOT_URL = 'https://flutter-shop-app-dbc34.firebaseio.com/';

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
    }
  );

  Future<void> toggleFavoriteStatus(String auth, String userId) async {
      var currentStatus = this.isFavorite;
      this.isFavorite = !this.isFavorite;
      notifyListeners();
      final productUrl = ROOT_URL + 'userFavorites/$userId/$id.json?auth=$auth';
      final response = await http.put(productUrl, body: json.encode(
        this.isFavorite
      ));
      if(response.statusCode >= 400) {
        this.isFavorite = currentStatus;
        notifyListeners();
        throw HttpException('Update failed.');
      }
  }
}