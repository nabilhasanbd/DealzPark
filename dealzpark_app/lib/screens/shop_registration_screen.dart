import 'package:flutter/material.dart';
import '../models/shop.dart';
import '../services/api_service.dart';

class ShopRegistrationScreen extends StatefulWidget {
  const ShopRegistrationScreen({Key? key}) : super(key: key);

  @override
  _ShopRegistrationScreenState createState() => _ShopRegistrationScreenState();
}

class _ShopRegistrationScreenState extends State<ShopRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  bool _isLoading = false;

  // Form field controllers
  final _shopNameController = TextEditingController();
  final _nidController = TextEditingController();
  final _tradeLicenseController = TextEditingController();
  final _productDetailsController = TextEditingController();
  final _locationController = TextEditingController();
  final _addressController = TextEditingController();
  final _shopTypeController = TextEditingController();

  @override
  void dispose() {
    _shopNameController.dispose();
    _nidController.dispose();
    _tradeLicenseController.dispose();
    _productDetailsController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    _shopTypeController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final data = ShopRegistrationData(
        shopName: _shopNameController.text,
        nid: _nidController.text,
        tradeLicense: _tradeLicenseController.text,
        productDetails: _productDetailsController.text,
        location: _locationController.text,
        address: _addressController.text,
        shopType: _shopTypeController.text,
      );

      try {
        await _apiService.registerShop(data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shop registered successfully!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(); // Go back after successful registration
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to register shop: $e'), backgroundColor: Colors.red),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Your Shop', style: TextStyle(color: Colors.white)),
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
                _buildTextFormField(_shopNameController, 'Shop or Company Name'),
                _buildTextFormField(_nidController, 'NID (National ID)'),
                _buildTextFormField(_tradeLicenseController, 'Trade License Number'),
                _buildTextFormField(_productDetailsController, 'Product Details (e.g., types of products)', isOptional: true, maxLines: 3),
                _buildTextFormField(_locationController, 'Location (e.g., City, Area)', isOptional: true),
                _buildTextFormField(_addressController, 'Full Address'),
                _buildTextFormField(_shopTypeController, 'Shop Type (e.g., Retail, Online)'),
                const SizedBox(height: 24),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                        icon: const Icon(Icons.app_registration),
                        label: const Text('Register Shop'),
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

  Widget _buildTextFormField(TextEditingController controller, String label, {bool isOptional = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label + (isOptional ? ' (Optional)' : ''),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        maxLines: maxLines,
        validator: (value) {
          if (!isOptional && (value == null || value.isEmpty)) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
}