import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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
  String? _selectedCategoryName;
  int? _selectedShopId;

  List<Shop> _shops = [];
  bool _shopsLoading = true;

  List<String> _categoriesForDropdown = [];

  @override
  void initState() {
    super.initState();
    _fetchShops();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final offerProvider = Provider.of<OfferProvider>(context, listen: false);
      setState(() {
        // Use categoryNamesForDropdown which excludes "All"
        // and is sourced from the API-fetched _allApiCategories
        _categoriesForDropdown = offerProvider.categoryNamesForDropdown;
        if (_categoriesForDropdown.isNotEmpty) {
          _selectedCategoryName = _categoriesForDropdown.first;
        }
      });
    });
  }

  Future<void> _fetchShops() async {
    if (!mounted) return;
    try {
      _shops = await _apiService.fetchShops();
      if (mounted && _shops.isNotEmpty) {
        setState(() {
          _selectedShopId = _shops.first.id;
        });
      }
    } catch (e) {
      print("Error fetching shops: $e");
      if (mounted) {
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

  Future<void> _submitForm() async {
    if (!mounted) return;

    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryName == null || _categoriesForDropdown.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a category. If none available, add one first.'), backgroundColor: Colors.orange),
        );
        return;
      }
      if (_validFrom == null || _validTo == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select both valid from and valid to dates.'), backgroundColor: Colors.orange),
        );
        return;
      }
      if (_validTo!.isBefore(_validFrom!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Valid To date must be after Valid From date.'), backgroundColor: Colors.orange),
        );
        return;
      }
      if (_selectedShopId == null && _shops.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a shop.'), backgroundColor: Colors.orange),
        );
        return;
      }
      if (_shops.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No shops available. Register one first.'), backgroundColor: Colors.orange),
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
        'category': _selectedCategoryName,
        'shopId': _selectedShopId,
      };

      try {
        await _apiService.addOffer(offerData);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Offer added successfully!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(true);
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Offer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (_shopsLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_shops.isEmpty)
                  const Text("No shops available. Register a shop first.")
                else
                  DropdownButtonFormField<int>(
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
                if (_categoriesForDropdown.isNotEmpty)
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Category'),
                    value: _selectedCategoryName,
                    items: _categoriesForDropdown.map((String categoryName) {
                      return DropdownMenuItem<String>(
                        value: categoryName,
                        child: Text(categoryName),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategoryName = newValue;
                      });
                    },
                    validator: (value) => value == null ? 'Please select a category' : null,
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      Provider.of<OfferProvider>(context, listen: false).isLoadingCategories
                          ? "Loading categories..."
                          : "No categories available. Please add categories via the 'Categories' tab first.",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setState(() {
                              _validFrom = picked;
                            });
                          }
                        },
                        child: Text(_validFrom == null ? 'Select Valid From' : 'From: ${formatter.format(_validFrom!)}'),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setState(() {
                              _validTo = picked;
                            });
                          }
                        },
                        child: Text(_validTo == null ? 'Select Valid To' : 'To: ${formatter.format(_validTo!)}'),
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
