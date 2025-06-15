import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/offer_provider.dart';
import '../models/category_model.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController _newCategoryController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isAddingCategory = false;

  @override
  void initState() {
    super.initState();
    // Fetch categories only if not already loaded and not currently being loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final offerProvider = Provider.of<OfferProvider>(context, listen: false);
      if (offerProvider.allApiCategories.isEmpty && !offerProvider.isLoadingCategories) {
        print("CategoriesScreen: Categories empty and not loading, fetching...");
        offerProvider.fetchAllCategoriesFromApi().catchError((error) {
          print("CategoriesScreen: Error fetching categories in initState: $error");
        });
      } else {
        print("CategoriesScreen: Categories already loaded or loading.");
      }
    });
  }

  @override
  void dispose() {
    _newCategoryController.dispose();
    super.dispose();
  }

  Future<void> _handleAddCategory() async {
    if (_formKey.currentState!.validate()) {
      final categoryName = _newCategoryController.text.trim();
      if (categoryName.isEmpty) return;

      setState(() => _isAddingCategory = true);
      try {
        await Provider.of<OfferProvider>(context, listen: false).addCategoryToApi(categoryName);
        _newCategoryController.clear();
        if (mounted) FocusScope.of(context).unfocus();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Category "$categoryName" added!'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add category: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isAddingCategory = false);
      }
    }
  }

  Future<void> _handleEditCategory(CategoryModel category) async {
    final TextEditingController editController = TextEditingController(text: category.name);
    final GlobalKey<FormState> editFormKey = GlobalKey<FormState>();
    String? newName = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Edit Category "${category.name}"'),
          content: Form(
            key: editFormKey,
            child: TextFormField(
              controller: editController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'New Category Name'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a category name.';
                }
                if (value.trim().toLowerCase() == category.name.toLowerCase()) {
                  return 'Name is the same.';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                if (editFormKey.currentState!.validate()) {
                  Navigator.of(dialogContext).pop(editController.text.trim());
                }
              },
            ),
          ],
        );
      },
    );

    if (newName != null && newName.isNotEmpty && newName.toLowerCase() != category.name.toLowerCase()) {
      try {
        await Provider.of<OfferProvider>(context, listen: false).editCategoryInApi(category.id, newName);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Category updated to "$newName"!'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update category: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _handleDeleteCategory(CategoryModel category) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Delete Category?'),
          content: Text('Are you sure you want to delete the category "${category.name}"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        await Provider.of<OfferProvider>(context, listen: false).deleteCategoryFromApi(category.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Category "${category.name}" deleted!'), backgroundColor: Colors.orange),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete category: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<OfferProvider>(
        builder: (context, offerProvider, child) {
          final categories = offerProvider.allApiCategories;
          final displayCategoryNames = offerProvider.displayCategoriesList;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Form(
                  key: _formKey,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _newCategoryController,
                          decoration: const InputDecoration(
                            labelText: 'New Category Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a category name.';
                            }
                            if (offerProvider.allApiCategories.any(
                                (c) => c.name.toLowerCase() == value.trim().toLowerCase())) {
                              return 'This category already exists.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      _isAddingCategory
                          ? const CircularProgressIndicator()
                          : ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Add'),
                              onPressed: _handleAddCategory,
                            ),
                    ],
                  ),
                ),
              ),
              const Divider(),
              if (offerProvider.isLoadingCategories && categories.isEmpty)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (categories.isEmpty)
                const Expanded(child: Center(child: Text('No categories found. Add one above!')))
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: displayCategoryNames.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final categoryName = displayCategoryNames[index];
                      final bool isAllCategory = categoryName.toLowerCase() == 'all';
                      CategoryModel? categoryModel;
                      if (!isAllCategory) {
                        categoryModel = categories.firstWhere(
                          (c) => c.name == categoryName,
                          orElse: () => CategoryModel(id: -1, name: categoryName, createdAt: DateTime.now()),
                        );
                      }

                      bool isSelected = offerProvider.selectedCategoryName == categoryName;

                      return ListTile(
                        title: Text(
                          categoryName,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Theme.of(context).primaryColor : null,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected)
                              Icon(Icons.check_circle, color: Theme.of(context).primaryColor),
                            if (!isAllCategory && categoryModel != null) ...[
                              IconButton(
                                icon: Icon(Icons.edit_outlined, color: Colors.blueGrey[600], size: 20),
                                onPressed: () => _handleEditCategory(categoryModel!),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete_outline, color: Colors.red[400], size: 20),
                                onPressed: () => _handleDeleteCategory(categoryModel!),
                              ),
                            ]
                          ],
                        ),
                        onTap: () {
                          offerProvider.selectCategoryAndFetch(categoryName);
                        },
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
