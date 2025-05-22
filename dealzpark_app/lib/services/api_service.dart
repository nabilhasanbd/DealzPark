import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/offer.dart';
import '../models/shop.dart'; // For ShopRegistrationData
import 'dart:io' show Platform; // For platform-specific base URL

class ApiService {
  // For Android emulator, 10.0.2.2 points to host machine's localhost
  // For iOS simulator or physical device, use your machine's local IP address
  // Make sure your .NET API is running and accessible.
  static String get baseUrl {
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:5015/api'; // Use the correct port (5015)
  } else {
    return 'http://localhost:5015/api'; // Use the correct port (5015)
  }
}


  Future<List<Offer>> fetchOffers({String? category}) async {
    String url = '$baseUrl/Offers';
    if (category != null && category.toLowerCase() != 'all') {
      url += '?category=${Uri.encodeComponent(category)}';
    }

    try {
      // For HTTPS with self-signed certs in dev, you might need to bypass certificate checks.
      // This is NOT recommended for production.
      // final client = HttpClient();
      // client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
      // final ioClient = IOClient(client);
      // final response = await ioClient.get(Uri.parse(url));

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
}