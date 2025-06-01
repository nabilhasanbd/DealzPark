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
    print('ApiService: Fetching categories from URL: $baseUrl/Categories');
    print('ApiService: Categories Response status: ${response.statusCode}');
    print('ApiService: Categories Response body: ${response.body}');

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<CategoryModel> categories =
          body.map((dynamic item) => CategoryModel.fromJson(item)).toList();
      return categories;
    } else {
      throw Exception('Failed to load categories: ${response.statusCode}');
    }
  }

  Future<CategoryModel> createCategory(String name) async {
    final String url = '$baseUrl/Categories';
    print('ApiService: Creating category at URL: $url with name: $name');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8', // CORRECT CHARSET
        },
        body: jsonEncode(<String, String>{ // Ensure the body matches your DTO
          'name': name,
        }),
      );

      print('ApiService: Create Category Response Status: ${response.statusCode}');
      print('ApiService: Create Category Response Body: ${response.body}');

      if (response.statusCode == 201) { // 201 Created
        // Assuming your API returns the created category object in the body
        return CategoryModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400) {
        // Try to parse error message if API provides one
        String errorMessage = 'Failed to create category: Bad Request';
        try {
          var decodedError = jsonDecode(response.body);
          if (decodedError is Map && decodedError.containsKey('message')) {
            errorMessage = decodedError['message'];
          } else if (decodedError is String) {
            errorMessage = decodedError;
          } else if (decodedError is Map && decodedError.containsKey('errors')) {
             // Handle ASP.NET Core Identity style errors
            var errorsMap = decodedError['errors'] as Map<String, dynamic>;
            if (errorsMap.isNotEmpty) {
                var firstErrorKey = errorsMap.keys.first;
                var errorMessages = errorsMap[firstErrorKey] as List<dynamic>;
                if (errorMessages.isNotEmpty) {
                    errorMessage = errorMessages.first.toString();
                }
            }
          }
        } catch (e) {
          // Ignore if error body is not JSON or not in expected format
        }
        print(errorMessage);
        throw Exception(errorMessage);
      }
      else {
        print('Failed to create category: ${response.statusCode}');
        throw Exception('Failed to create category. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('ApiService: Error creating category: $e');
      throw Exception('Error creating category: $e');
    }
  }
}