import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;

  Future<void> _authenticate(String email, String password, String urlSegment) async {
    final url =
        "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyAbf-bQCkBd7R9mETgNyFu8973cgUEDO1g";

    try {
      var response = await http.post(url,
        body: json.encode(
            {
              'email': email, 
              'password': password, 
              'returnSecureToken': true
            }
          )
        );
      var reseponseData = json.decode(response.body);
      print(reseponseData);
      if(reseponseData['error'] != null) {
        throw HttpException(reseponseData['error']['message']);
      }
    } catch(error) {
      throw error;
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> signIn(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }
}
