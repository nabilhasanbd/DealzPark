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
    await fetchAllCategoriesFromApi();
    await loadOffers(category: _selectedCategoryName);
  }

//TODO
  Future<void> fetchAllCategoriesFromApi() async {
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
      await fetchAllCategoriesFromApi();
    } catch (e) {
      print("Error adding category: $e");
      throw e;
    }
  }

  Future<void> addCategoryToApi(String name) async {
    // Optional: Add optimistic update here if desired
    try {
      await _apiService.createCategory(name);
      await fetchAllCategoriesFromApi(); // Refresh the list from API
    } catch (e) {
      print("OfferProvider - Error adding category: $e");
      rethrow; // Rethrow to be caught by UI for user feedback
    }
  }

  Future<void> editCategoryInApi(int categoryId, String newName) async {
    try {
      await _apiService.updateCategory(categoryId, newName);
      await fetchAllCategoriesFromApi(); // Refresh
    } catch (e) {
      print("OfferProvider - Error editing category: $e");
      rethrow;
    }
  }

  Future<void> deleteCategoryFromApi(int categoryId) async {
    try {
      await _apiService.deleteCategory(categoryId);
      // If the deleted category was the selected one, reset selection to 'All'
      if (_allApiCategories.any((c) => c.id == categoryId && c.name == _selectedCategoryName)) {
          _selectedCategoryName = 'All';
      }
      await fetchAllCategoriesFromApi(); // Refresh
      await loadOffers(category: _selectedCategoryName); // Reload offers based on potentially new selection
    } catch (e) {
      print("OfferProvider - Error deleting category: $e");
      rethrow;
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
