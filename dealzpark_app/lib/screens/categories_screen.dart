import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/offer_provider.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController _categoryNameController = TextEditingController();
  final FocusNode _categoryFocusNode = FocusNode();
  bool _isAddingCategory = false;

  Future<void> _submitNewCategory(BuildContext context) async {
    if (_categoryNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category name cannot be empty.'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() {
      _isAddingCategory = true;
    });

    final offerProvider = Provider.of<OfferProvider>(context, listen: false);
    try {
      await offerProvider.addCategory(_categoryNameController.text.trim());
      _categoryNameController.clear();
      _categoryFocusNode.unfocus();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category added successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add category: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingCategory = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _categoryNameController.dispose();
    _categoryFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final offerProvider = Provider.of<OfferProvider>(context);
    final displayCategories = offerProvider.displayCategoriesList;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Categories'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _categoryNameController,
                    focusNode: _categoryFocusNode,
                    decoration: const InputDecoration(
                      labelText: 'New Category Name',
                      hintText: 'e.g. Health & Beauty',
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submitNewCategory(context),
                  ),
                ),
                const SizedBox(width: 10),
                _isAddingCategory
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        onPressed: () => _submitNewCategory(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                      )
              ],
            ),
          ),
          const Divider(),
          if (offerProvider.isLoadingCategories)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (displayCategories.isEmpty)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "No categories found. Add some to get started!",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: displayCategories.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final categoryName = displayCategories[index];
                  bool isSelected = offerProvider.selectedCategoryName.toLowerCase() == categoryName.toLowerCase();

                  return ListTile(
                    title: Text(
                      categoryName,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Theme.of(context).primaryColor : null,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
                        : null,
                    onTap: () {
                      offerProvider.selectCategoryAndFetch(categoryName);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Showing deals for $categoryName')),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
