import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../services/api_service.dart';
import '../models/shop.dart';
import '../providers/offer_provider.dart';

class AddOfferScreen extends StatefulWidget {
  const AddOfferScreen({Key? key}) : super(key: key);

  @override
  _AddOfferScreenState createState() => _AddOfferScreenState();
}

class _AddOfferScreenState extends State<AddOfferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  bool _isLoading = false;

  final _titleController = TextEditingController();
  final _promoImageUrlController = TextEditingController();
  final _discountController = TextEditingController();
  final _productImageUrlController = TextEditingController();
  DateTime? _validFrom;
  DateTime? _validTo;
  String? _selectedCategory;
  int? _selectedShopId;

  List<Shop> _shops = [];
  bool _shopsLoading = true;

  // To store categories for the dropdown, fetched from OfferProvider
  List<String> _categoriesForDropdown = [];

  @override
  void initState() {
    super.initState();
    _fetchShops();

    // Fetch categories from OfferProvider once
    // Use addPostFrameCallback to ensure context is available for Provider.of
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final offerProvider = Provider.of<OfferProvider>(context, listen: false);
      setState(() {
        _categoriesForDropdown = offerProvider.allCategories
            .where((c) => c.toLowerCase() != 'all') // Exclude 'All'
            .toList();
        if (_categoriesForDropdown.isNotEmpty) {
          _selectedCategory = _categoriesForDropdown.first; // Default to first category
        }
      });
    });
  }

  Future<void> _fetchShops() async {
    // Ensure context is mounted before showing SnackBar
    if (!mounted) return;
    try {
      _shops = await _apiService.fetchShops();
      if (_shops.isNotEmpty) {
        _selectedShopId = _shops.first.id;
      }
    } catch (e) {
      print("Error fetching shops: $e");
      if (mounted) { // Check if widget is still in the tree
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching shops: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _shopsLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _promoImageUrlController.dispose();
    _discountController.dispose();
    _productImageUrlController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isFromDate ? _validFrom : _validTo) ?? DateTime.now(),
      firstDate: DateTime(2000), // Allow past dates for 'Valid From' if needed
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _validFrom = picked;
        } else {
          _validTo = picked;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (!mounted) return; // Check if widget is still in the tree

    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a category.'), backgroundColor: Colors.orange),
        );
        return;
      }
      if (_validFrom == null || _validTo == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select validity dates.'), backgroundColor: Colors.orange),
        );
        return;
      }
      if (_validTo!.isBefore(_validFrom!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Valid To date cannot be before Valid From date.'), backgroundColor: Colors.orange),
        );
        return;
      }
      if (_selectedShopId == null && _shops.isNotEmpty) { // Check if shops were loaded but none selected
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a shop.'), backgroundColor: Colors.orange),
        );
        return;
      }
       if (_shops.isEmpty) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No shops available. Please register a shop first.'), backgroundColor: Colors.red),
        );
        return;
      }


      setState(() => _isLoading = true);

      final offerData = {
        'promotionalTitle': _titleController.text,
        'promotionalImageUrl': _promoImageUrlController.text.trim().isEmpty ? null : _promoImageUrlController.text.trim(),
        'discountPercentage': int.parse(_discountController.text),
        'productImageUrl': _productImageUrlController.text.trim().isEmpty ? null : _productImageUrlController.text.trim(),
        'validFrom': _validFrom!.toIso8601String(),
        'validTo': _validTo!.toIso8601String(),
        'category': _selectedCategory,
        'shopId': _selectedShopId,
      };

      try {
        await _apiService.addOffer(offerData);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Offer added successfully!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(true); // Pop and indicate success
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add offer: $e'), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    // _categoriesForDropdown is now populated in initState

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Offer'),
        // Style inherited from main.dart's appBarTheme
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Shop Selector
                if (_shopsLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_shops.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      "No shops available to post offers. Please register a shop first.",
                      style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  DropdownButtonFormField<int>(
                    // decoration: InputDecoration(labelText: 'Select Shop'), // Uses theme
                    decoration: const InputDecoration(labelText: 'Select Shop'),
                    value: _selectedShopId,
                    items: _shops.map((Shop shop) {
                      return DropdownMenuItem<int>(
                        value: shop.id,
                        child: Text(shop.shopName),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      setState(() {
                        _selectedShopId = newValue;
                      });
                    },
                    validator: (value) => value == null ? 'Please select a shop' : null,
                  ),
                const SizedBox(height: 16),

                _buildTextFormField(_titleController, 'Promotional Title'),
                _buildTextFormField(_promoImageUrlController, 'Promotional Image URL (Optional)', isOptional: true),
                _buildTextFormField(_discountController, 'Discount Percentage (e.g. 50 for 50%)', keyboardType: TextInputType.number),
                _buildTextFormField(_productImageUrlController, 'Product Image URL (Optional)', isOptional: true),

                // Category Dropdown
                if (_categoriesForDropdown.isNotEmpty)
                  DropdownButtonFormField<String>(
                    // decoration: InputDecoration(labelText: 'Category'), // Uses theme
                    decoration: const InputDecoration(labelText: 'Category'),
                    value: _selectedCategory,
                    items: _categoriesForDropdown.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    },
                    validator: (value) => value == null ? 'Please select a category' : null,
                  )
                else
                  const Text("Loading categories..."), // Or handle no categories state
                const SizedBox(height: 16),

                // Date Pickers
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, true),
                        child: InputDecorator(
                          // decoration: InputDecoration(labelText: 'Valid From'), // Uses theme
                          decoration: const InputDecoration(labelText: 'Valid From'),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(_validFrom == null ? 'Select Date' : formatter.format(_validFrom!)),
                              const Icon(Icons.calendar_today, size: 20.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, false),
                        child: InputDecorator(
                          // decoration: InputDecoration(labelText: 'Valid To'), // Uses theme
                          decoration: const InputDecoration(labelText: 'Valid To'),
                           child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(_validTo == null ? 'Select Date' : formatter.format(_validTo!)),
                              const Icon(Icons.calendar_today, size: 20.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                        icon: const Icon(Icons.post_add),
                        label: const Text('Post Offer'),
                        onPressed: _submitForm,
                        // Style inherited from main.dart's elevatedButtonTheme
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String label, {bool isOptional = false, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        // decoration: InputDecoration(labelText: label), // Uses theme
        decoration: InputDecoration(labelText: label + (isOptional ? ' (Optional)' : '')),
        keyboardType: keyboardType,
        validator: (value) {
          if (!isOptional && (value == null || value.trim().isEmpty)) {
            return 'Please enter $label';
          }
          if (label.contains('Discount') && value != null && value.trim().isNotEmpty) {
            final discount = int.tryParse(value.trim());
            if (discount == null || discount < 0 || discount > 100) {
              return 'Discount must be between 0 and 100';
            }
          }
          return null;
        },
      ),
    );
  }
}