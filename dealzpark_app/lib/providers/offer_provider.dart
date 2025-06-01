import 'package:flutter/material.dart';
import '../models/offer.dart';
import '../models/category_model.dart';
import '../services/api_service.dart';

class OfferProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Offer> _offers = [];
  bool _isLoadingOffers = false;
  String _selectedCategoryName = 'All';

  List<CategoryModel> _allApiCategories = [];
  bool _isLoadingCategories = false;

  List<Offer> get offers => _offers;
  bool get isLoadingOffers => _isLoadingOffers;
  String get selectedCategoryName => _selectedCategoryName;

  List<CategoryModel> get allApiCategories => _allApiCategories;
  bool get isLoadingCategories => _isLoadingCategories;

  List<String> get categoryNamesForDropdown =>
      _allApiCategories.map((c) => c.name).toList();

  List<String> get displayCategoriesList {
    final names = _allApiCategories.map((c) => c.name).toList();
    if (!names.map((n) => n.toLowerCase()).contains('all')) {
      return ['All', ...names];
    }
    return names;
  }

  OfferProvider() {
    initializeData();
  }

  Future<void> initializeData() async {
    await fetchAllCategories();
    await loadOffers(category: _selectedCategoryName);
  }

  Future<void> fetchAllCategories() async {
    _isLoadingCategories = true;
    notifyListeners();
    try {
      _allApiCategories = await _apiService.fetchCategories();
      _allApiCategories.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } catch (e) {
      print("Error fetching categories: $e");
      _allApiCategories = [];
    }
    _isLoadingCategories = false;
    notifyListeners();
  }

  Future<void> addCategory(String name) async {
    try {
      await _apiService.createCategory(name);
      await fetchAllCategories();
    } catch (e) {
      print("Error adding category: $e");
      throw e;
    }
  }

  Future<void> loadOffers({String? category, bool forceApiCall = false}) async {
    final categoryToFetch = (category == null || category.toLowerCase() == 'all') ? null : category;

    if (category != null) {
      _selectedCategoryName = category;
    }

    _isLoadingOffers = true;
    notifyListeners();

    try {
      _offers = await _apiService.fetchOffers(category: categoryToFetch);
    } catch (e) {
      print("Error fetching offers: $e");
      _offers = [];
    }

    _isLoadingOffers = false;
    notifyListeners();
  }

  void selectCategoryAndFetch(String categoryName) {
    _selectedCategoryName = categoryName;
    loadOffers(category: categoryName, forceApiCall: true);
  }
}
