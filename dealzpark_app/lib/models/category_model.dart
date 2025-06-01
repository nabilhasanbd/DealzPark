class CategoryModel { // Renamed to CategoryModel to avoid conflict with Flutter's Category widget
  final int id;
  final String name;
  final DateTime createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Not strictly needed for this flow, but good practice if you might send it as JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}