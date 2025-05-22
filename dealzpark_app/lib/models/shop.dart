class ShopRegistrationData {
  final String shopName;
  final String nid;
  final String tradeLicense;
  final String? productDetails;
  final String? location;
  final String address;
  final String shopType;

  ShopRegistrationData({
    required this.shopName,
    required this.nid,
    required this.tradeLicense,
    this.productDetails,
    this.location,
    required this.address,
    required this.shopType,
  });

  Map<String, dynamic> toJson() {
    return {
      'shopName': shopName,
      'nid': nid,
      'tradeLicense': tradeLicense,
      'productDetails': productDetails,
      'location': location,
      'address': address,
      'shopType': shopType,
    };
  }
}

// If you need to display shop details elsewhere
class Shop {
  final int id;
  final String shopName;
  // ... other fields if needed

  Shop({required this.id, required this.shopName});

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'],
      shopName: json['shopName'],
    );
  }
}