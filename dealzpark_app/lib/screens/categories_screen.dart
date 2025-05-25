
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/offer_provider.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final offerProvider = Provider.of<OfferProvider>(context, listen: false);
    // Use the allCategories list from the provider
    final categories = offerProvider.allCategories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Categories'),
        automaticallyImplyLeading: false, // No back button if it's a main tab
      ),
      body: ListView.separated(
        itemCount: categories.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final category = categories[index];
          bool isSelected = offerProvider.selectedCategory == category;

          return ListTile(
            title: Text(
              category,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Theme.of(context).primaryColor : null,
              ),
            ),
            trailing: isSelected
                ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
                : null,
            onTap: () {
              // Set the category in the provider AND trigger a fetch
              offerProvider.selectCategoryAndFetch(category);

              // Optional: If this screen is part of a PageView in HomeScreen,
              // you might want to switch back to the "Featured" tab.
              // This depends on how you structure your HomeScreen's PageView.
              // For now, we assume the user stays on this screen or navigates
              // back manually if it's pushed as a separate route.
              // If it's a tab, the home screen's offer list will update automatically.

              // If you want to pop this screen and show the deals for the selected category:
              // Navigator.of(context).pop(); // This would require HomeScreen's PageController to switch to index 0

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Showing deals for $category')),
              );
            },
          );
        },
      ),
    );
  }
}