import 'package:flutter/material.dart';
import '../models/offer.dart';
import '../services/api_service.dart';

class OfferProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Offer> _offers = [];
  List<Offer> _filteredOffers = [];
  bool _isLoading = false;
  String _selectedCategory = 'All'; // Default category

  List<Offer> get offers => _filteredOffers;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;

  final List<String> categories = [
    'All', 'Fashion', 'Electronics', 'Food', 'Sports', 'Travel', 'Services', 'Other'
  ];

  OfferProvider() {
    loadOffers(); // Load all offers initially
  }

  Future<void> loadOffers({String? category}) async {
    _isLoading = true;
    notifyListeners();
    try {
      _offers = await _apiService.fetchOffers(category: category ?? _selectedCategory);
      _applyFilter(); // Apply current category filter
    } catch (e) {
      print(e);
      _offers = []; // Clear offers on error
      _filteredOffers = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    _applyFilter();
    notifyListeners();
    // Optionally, re-fetch from API if server-side filtering is preferred for all categories
    // loadOffers(category: category == 'All' ? null : category);
  }

  void _applyFilter() {
    if (_selectedCategory.toLowerCase() == 'all') {
      _filteredOffers = List.from(_offers);
    } else {
      _filteredOffers = _offers.where((offer) =>
        offer.category.toLowerCase() == _selectedCategory.toLowerCase()
      ).toList();
    }
  }
}