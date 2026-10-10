// PART 2 version: no error handling yet (added in Part 3).
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/item.dart';

class ApiClient {
  final http.Client _http;
  final bool _ownsClient;

  void close() {
    if (_ownsClient) _http.close();
  }

  ApiClient({http.Client? client}) : _ownsClient = client == null, _http = client ?? http.Client();

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('$baseUrl$path').replace(queryParameters: query);

  Future<List<Item>> getItems() async {
    final res = await _http.get(_uri('/items'));
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((e) => Item.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Item> createItem(String name, double price) async {
    final res = await _http.post(
      _uri('/items'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'price': price}),
    );
    return Item.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }
}
