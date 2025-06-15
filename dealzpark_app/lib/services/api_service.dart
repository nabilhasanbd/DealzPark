import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/offer.dart';
import '../models/shop.dart'; // For ShopRegistrationData
import '../models/category_model.dart';
import 'dart:io' show Platform; // For platform-specific base URL

class ApiService {

  static String get baseUrl {
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:5015/api'; 
  } else {
    return 'http://localhost:5015/api'; 
  }
}


  Future<List<Offer>> fetchOffers({String? category}) async {
    String url = '$baseUrl/Offers';
    if (category != null && category.toLowerCase() != 'all') {
      url += '?category=${Uri.encodeComponent(category)}';
    }

    try {

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        List<Offer> offers =
            body.map((dynamic item) => Offer.fromJson(item)).toList();
        return offers;
      } else {
        print('Failed to load offers: ${response.statusCode} ${response.body}');
        throw Exception('Failed to load offers');
      }
    } catch (e) {
      print('Error fetching offers: $e');
      throw Exception('Error fetching offers: $e');
    }
  }

  Future<Offer> fetchOfferDetails(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/Offers/$id'));
    if (response.statusCode == 200) {
      return Offer.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load offer details');
    }
  }

  Future<Map<String, dynamic>> registerShop(ShopRegistrationData data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Shops/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data.toJson()),
    );
    if (response.statusCode == 201) { // Created
      return jsonDecode(response.body); // Returns the created shop with its ID
    } else {
      print('Failed to register shop: ${response.statusCode} ${response.body}');
      throw Exception('Failed to register shop: ${response.body}');
    }
  }

  Future<void> addOffer(Map<String, dynamic> offerData) async {
    // Ensure DateTime is formatted correctly for the backend (ISO 8601)
    if (offerData['validFrom'] is DateTime) {
      offerData['validFrom'] = (offerData['validFrom'] as DateTime).toIso8601String();
    }
    if (offerData['validTo'] is DateTime) {
      offerData['validTo'] = (offerData['validTo'] as DateTime).toIso8601String();
    }
    
    final response = await http.post(
      Uri.parse('$baseUrl/Offers'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(offerData),
    );

    if (response.statusCode == 201) {
      print('Offer added successfully');
    } else {
      print('Failed to add offer: ${response.statusCode} ${response.body}');
      throw Exception('Failed to add offer: ${response.body}');
    }
  }

   Future<List<Shop>> fetchShops() async {
    final response = await http.get(Uri.parse('$baseUrl/Shops'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Shop> shops = body.map((dynamic item) => Shop.fromJson(item)).toList();
      return shops;
    } else {
      throw Exception('Failed to load shops');
    }
  }

  Future<List<CategoryModel>> fetchCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/Categories'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<CategoryModel> categories =
          body.map((dynamic item) => CategoryModel.fromJson(item)).toList();
      return categories;
    } else {
      print('Failed to load categories: ${response.statusCode} ${response.body}');
      throw Exception('Failed to load categories');
    }
  }

  Future<CategoryModel> createCategory(String name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Categories'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'name': name}),
    );
    if (response.statusCode == 201) {
      return CategoryModel.fromJson(jsonDecode(response.body));
    } else {
      String errorMessage = 'Failed to create category.';
      try {
        var decodedError = jsonDecode(response.body);
         if (decodedError is String) {
          errorMessage = decodedError;
        } else if (decodedError is Map && decodedError.containsKey('message')) {
          errorMessage = decodedError['message'];
        } else if (decodedError is Map && decodedError.values.isNotEmpty && decodedError.values.first is List) {
           // ASP.NET Core validation errors often come as a map of lists
          errorMessage = (decodedError.values.first as List).first.toString();
        } else if (response.body.isNotEmpty) {
          errorMessage = response.body;
        }
      } catch (e) { /* Ignore parsing error, use default message */ }
      print('Failed to create category: ${response.statusCode} - $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<void> updateCategory(int id, String newName) async {
    final response = await http.put(
      Uri.parse('$baseUrl/Categories/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'name': newName}),
    );
    if (response.statusCode == 204) { // No Content for successful PUT
      print('Category updated successfully');
    } else {
       String errorMessage = 'Failed to update category.';
      try {
        var decodedError = jsonDecode(response.body);
        if (decodedError is String) {
          errorMessage = decodedError;
        } else if (decodedError is Map && decodedError.containsKey('message')) {
          errorMessage = decodedError['message'];
        } else if (decodedError is Map && decodedError.values.isNotEmpty && decodedError.values.first is List) {
          errorMessage = (decodedError.values.first as List).first.toString();
        } else if (response.body.isNotEmpty) {
          errorMessage = response.body;
        }
      } catch (e) { /* Ignore */ }
      print('Failed to update category: ${response.statusCode} - $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<void> deleteCategory(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/Categories/$id'));
    if (response.statusCode == 204) { // No Content for successful DELETE
      print('Category deleted successfully');
    } else {
      String errorMessage = 'Failed to delete category.';
      try {
        var decodedError = jsonDecode(response.body);
         if (decodedError is String) {
          errorMessage = decodedError;
        } else if (decodedError is Map && decodedError.containsKey('message')) {
          errorMessage = decodedError['message'];
        } else if (response.body.isNotEmpty) {
           errorMessage = response.body; // API might just return plain text for 400 error
        }
      } catch (e) { /* Ignore */ }
      print('Failed to delete category: ${response.statusCode} - $errorMessage');
      throw Exception(errorMessage);
    }
  }
}