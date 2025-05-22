class Offer {
  final int id;
  final String promotionalTitle;
  final String? promotionalImageUrl;
  final int discountPercentage;
  final String? productImageUrl;
  final DateTime validFrom;
  final DateTime validTo;
  final DateTime createdAt;
  final String category;
  final int shopId;
  final String shopName;

  Offer({
    required this.id,
    required this.promotionalTitle,
    this.promotionalImageUrl,
    required this.discountPercentage,
    this.productImageUrl,
    required this.validFrom,
    required this.validTo,
    required this.createdAt,
    required this.category,
    required this.shopId,
    required this.shopName,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'],
      promotionalTitle: json['promotionalTitle'],
      promotionalImageUrl: json['promotionalImageUrl'],
      discountPercentage: json['discountPercentage'],
      productImageUrl: json['productImageUrl'],
      validFrom: DateTime.parse(json['validFrom']),
      validTo: DateTime.parse(json['validTo']),
      createdAt: DateTime.parse(json['createdAt']),
      category: json['category'],
      shopId: json['shopId'],
      shopName: json['shopName'],
    );
  }
}