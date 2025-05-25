import 'package:flutter/material.dart';
import '../models/offer.dart';
import '../services/api_service.dart';

class OfferProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Offer> _offers = []; // All offers fetched for the current view
  // List<Offer> _filteredOffers = []; // We might not need this if we refetch on category change
  bool _isLoading = false;
  String _selectedCategory = 'All'; // Default category, or initially null then set

  List<Offer> get offers => _offers; // Directly return _offers
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;

  // Categories list for the CategoriesScreen and potentially for other uses
  final List<String> allCategories = [
    'All', 'Fashion', 'Electronics', 'Food', 'Sports', 'Travel', 'Services', 'Other'
  ];

  OfferProvider() {
    // Load "All" offers initially when the provider is created for the home screen
    loadOffers(category: 'All');
  }

  Future<void> loadOffers({String? category, bool forceApiCall = false}) async {
    // If category is null or "All", we fetch all.
    // If a specific category is provided, we fetch for that category.
    final categoryToFetch = (category == null || category.toLowerCase() == 'all') ? null : category;

    // Only update selectedCategory if a new one is explicitly passed
    // (e.g., from CategoriesScreen or if we had top filters)
    if (category != null) {
      _selectedCategory = category;
    }
    
    _isLoading = true;
    notifyListeners(); // Notify UI that loading has started

    try {
      _offers = await _apiService.fetchOffers(category: categoryToFetch);
    } catch (e) {
      print(e);
      _offers = []; // Clear offers on error
    }
    _isLoading = false;
    notifyListeners(); // Notify UI that data is loaded or loading failed
  }

  // This method will be called from the CategoriesScreen when a category is tapped
  void selectCategoryAndFetch(String category) {
    _selectedCategory = category;
    // We always want to fetch from API when category changes from CategoriesScreen
    loadOffers(category: category, forceApiCall: true);
    notifyListeners(); // Ensure UI updates if selectedCategory is observed elsewhere
  }
}