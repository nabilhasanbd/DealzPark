import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/shop.dart'; // For Shop model if needed for dropdown
import '../providers/offer_provider.dart'; // For categories list

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

  List<Shop> _shops = []; // To populate shop dropdown
  bool _shopsLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchShops();
  }

  Future<void> _fetchShops() async {
    try {
      _shops = await _apiService.fetchShops();
      if (_shops.isNotEmpty) {
        _selectedShopId = _shops.first.id; // Default to first shop
      }
    } catch (e) {
      print("Error fetching shops: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching shops: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _shopsLoading = false);
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
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)), // Can be older if needed
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
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
    if (_formKey.currentState!.validate()) {
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
       if (_selectedShopId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a shop.'), backgroundColor: Colors.orange),
        );
        return;
      }

      setState(() => _isLoading = true);

      final offerData = {
        'promotionalTitle': _titleController.text,
        'promotionalImageUrl': _promoImageUrlController.text.isEmpty ? null : _promoImageUrlController.text,
        'discountPercentage': int.parse(_discountController.text),
        'productImageUrl': _productImageUrlController.text.isEmpty ? null : _productImageUrlController.text,
        'validFrom': _validFrom!.toIso8601String(),
        'validTo': _validTo!.toIso8601String(),
        'category': _selectedCategory,
        'shopId': _selectedShopId,
      };

      try {
        await _apiService.addOffer(offerData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Offer added successfully!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(true); // Pop and indicate success
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add offer: $e'), backgroundColor: Colors.red),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    // Using a predefined list of categories for simplicity
    final List<String> categories = OfferProvider().categories.where((c) => c != 'All').toList();
    if (_selectedCategory == null && categories.isNotEmpty) {
      _selectedCategory = categories.first;
    }


    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Offer', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
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
                  const Center(child: CircularProgressIndicator())
                else if (_shops.isEmpty)
                  const Text("No shops available to post offers. Please register a shop first.", style: TextStyle(color: Colors.red))
                else
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: 'Select Shop',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
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
                const SizedBox(height: 12),

                _buildTextFormField(_titleController, 'Promotional Title'),
                _buildTextFormField(_promoImageUrlController, 'Promotional Image URL (Optional)', isOptional: true),
                _buildTextFormField(_discountController, 'Discount Percentage (1-100)', keyboardType: TextInputType.number),
                _buildTextFormField(_productImageUrlController, 'Product Image URL (Optional)', isOptional: true),

                // Category Dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  value: _selectedCategory,
                  items: categories.map((String category) {
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
                ),
                const SizedBox(height: 12),

                // Date Pickers
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, true),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Valid From',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          child: Text(_validFrom == null ? 'Select Date' : formatter.format(_validFrom!)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, false),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Valid To',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          child: Text(_validTo == null ? 'Select Date' : formatter.format(_validTo!)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                        icon: const Icon(Icons.post_add),
                        label: const Text('Post Offer'),
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                           foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
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
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        keyboardType: keyboardType,
        validator: (value) {
          if (!isOptional && (value == null || value.isEmpty)) {
            return 'Please enter $label';
          }
          if (label.contains('Discount') && value != null && value.isNotEmpty) {
            final discount = int.tryParse(value);
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