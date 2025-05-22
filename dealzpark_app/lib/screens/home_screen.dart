import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/offer_provider.dart';
import '../widgets/offer_card.dart';
import '../widgets/category_chip.dart';
import 'shop_registration_screen.dart';
import 'add_offer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Map<String, IconData> categoryIcons = {
    'All': Icons.apps,
    'Fashion': Icons.style, // or Icons.shopping_bag
    'Electronics': Icons.devices,
    'Food': Icons.restaurant,
    'Sports': Icons.sports_soccer,
    'Travel': Icons.flight,
    'Services': Icons.miscellaneous_services,
    'Other': Icons.category,
  };

  @override
  void initState() {
    super.initState();
    // Fetch offers when the screen is initialized
    // Use addPostFrameCallback to ensure context is available for Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OfferProvider>(context, listen: false).loadOffers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final offerProvider = Provider.of<OfferProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DealzPark', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF6A1B9A), // Purple color
        elevation: 0,
        actions: [
          // Simple Login/Register placeholder buttons
          IconButton(
            icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
            tooltip: 'Register Shop',
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const ShopRegistrationScreen(),
              ));
            },
          ),
          IconButton(
            icon: const Icon(Icons.login, color: Colors.white),
            tooltip: 'Login (Placeholder)',
            onPressed: () {
              // Implement login functionality later
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Login functionality not yet implemented.')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // Search Bar Placeholder
          Container(
            padding: const EdgeInsets.all(16.0),
            color: const Color(0xFF6A1B9A), // Purple color
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search deals...',
                hintStyle: TextStyle(color: Colors.purple[100]),
                prefixIcon: Icon(Icons.search, color: Colors.purple[100]),
                filled: true,
                fillColor: Colors.purple[700], // Darker purple for contrast
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
              onChanged: (value) {
                // Implement search logic if needed
              },
            ),
          ),
          // Categories
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
            color: Colors.white, // Or a very light purple
            child: SizedBox(
              height: 80, // Adjust height as needed
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: offerProvider.categories.length,
                itemBuilder: (context, index) {
                  final category = offerProvider.categories[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: CategoryChip(
                      label: category,
                      icon: categoryIcons[category] ?? Icons.category,
                      isSelected: offerProvider.selectedCategory == category,
                      onTap: () {
                        offerProvider.setSelectedCategory(category);
                        // Re-fetch from API with category filter if using server-side filtering for all
                        // offerProvider.loadOffers(category: category == 'All' ? null : category);
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          // Offers List
          Expanded(
            child: offerProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : offerProvider.offers.isEmpty
                    ? Center(
                        child: Text(
                          'No deals found for ${offerProvider.selectedCategory}.\nTry another category or check back later!',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => offerProvider.loadOffers(),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(top: 8.0),
                          itemCount: offerProvider.offers.length,
                          itemBuilder: (ctx, i) => OfferCard(offer: offerProvider.offers[i]),
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const AddOfferScreen(),
          )).then((_) {
            // Refresh offers list after adding a new one
            offerProvider.loadOffers();
          });
        },
        label: const Text('Add Offer'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.orangeAccent,
      ),
    );
  }
}