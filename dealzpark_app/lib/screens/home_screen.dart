import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/offer_provider.dart';
import '../widgets/offer_card.dart';
// import '../widgets/category_chip.dart'; // We might replace this or style it differently
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
    'Fashion': Icons.shopping_bag_outlined,
    'Electronics': Icons.devices_other_outlined,
    'Food': Icons.restaurant_outlined,
    'Sports': Icons.sports_soccer_outlined,
    'Travel': Icons.flight_takeoff_outlined,
    'Services': Icons.miscellaneous_services_outlined,
    'Other': Icons.category_outlined,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OfferProvider>(context, listen: false).loadOffers();
    });
  }

  Widget _buildCategoryItem(BuildContext context, String category, OfferProvider offerProvider) {
    bool isSelected = offerProvider.selectedCategory == category;
    return InkWell(
      onTap: () {
        offerProvider.setSelectedCategory(category);
        offerProvider.loadOffers(category: category == 'All' ? null : category);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 90, // Fixed width for category items
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              categoryIcons[category] ?? Icons.category,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade700,
              size: 28,
            ),
            const SizedBox(height: 5),
            Text(
              category,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade800,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final offerProvider = Provider.of<OfferProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DealzPark', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_outlined, color: Colors.white),
            tooltip: 'Register Shop',
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const ShopRegistrationScreen(),
              ));
            },
          ),
          IconButton(
            icon: const Icon(Icons.login_outlined, color: Colors.white),
            tooltip: 'Login (Placeholder)',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Login functionality not yet implemented.')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // Search Bar (More Groupon-like)
          Container(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
            color: Theme.of(context).scaffoldBackgroundColor, // Or Colors.white
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search deals (e.g. Pizza, Spa)',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.white, // Or Colors.grey[200]
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              ),
              onChanged: (value) {
                // Implement search logic
              },
            ),
          ),

          // Categories Section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            color: Theme.of(context).scaffoldBackgroundColor, // Or Colors.white
            height: 95, // Adjust height for new category item
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              scrollDirection: Axis.horizontal,
              itemCount: offerProvider.categories.length,
              itemBuilder: (context, index) {
                final category = offerProvider.categories[index];
                return _buildCategoryItem(context, category, offerProvider);
              },
            ),
          ),
          const Divider(height: 1, thickness: 1),

          // Offers List
          Expanded(
            child: offerProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : offerProvider.offers.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            'No deals found for "${offerProvider.selectedCategory}".\nTry another category or check back later!',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => offerProvider.loadOffers(category: offerProvider.selectedCategory == 'All' ? null : offerProvider.selectedCategory),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(top: 4.0, bottom: 70.0), // Added bottom padding for FAB
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
          )).then((value) {
            if (value == true) { // Check if offer was successfully added
              offerProvider.loadOffers(category: offerProvider.selectedCategory == 'All' ? null : offerProvider.selectedCategory);
            }
          });
        },
        label: const Text('Add Offer'),
        icon: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}