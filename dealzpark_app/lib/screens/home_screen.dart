import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/offer_provider.dart';
import '../widgets/offer_card.dart';
import 'categories_screen.dart'; // Import the new screen
import 'shop_registration_screen.dart';
import 'add_offer_screen.dart';

// Placeholder screens for other tabs
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text("Notifications")),
    body: const Center(child: Text('Notifications Screen')),
  );
}

class SavedScreen extends StatelessWidget {
  const SavedScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text("Saved Deals")),
    body: const Center(child: Text('Saved Deals Screen')),
  );
}

class MyStuffScreen extends StatelessWidget {
  const MyStuffScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text("My Stuff / Profile")),
    body: const Center(child: Text('My Stuff Screen')),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  // No need to initialize _pages in initState with widget instances
  // that call Provider.of directly with the _HomeScreenState's context.

  @override
  void initState() {
    super.initState();
    // Initial offer loading is handled by OfferProvider's constructor.
    // Or, if it needed context and had to be one-time, you might use:
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (mounted) { // Good practice to check if mounted
    //     Provider.of<OfferProvider>(context, listen: false).loadOffers(category: 'All');
    //   }
    // });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    // Prevent unnecessary rebuilds or actions if the same tab is tapped
    if (_currentIndex == index) {
        if (index == 0) { // If featured tab is tapped again, refresh
            final offerProvider = Provider.of<OfferProvider>(context, listen: false);
            offerProvider.loadOffers(category: offerProvider.selectedCategory);
        }
        return; // Do nothing further if it's the same tab
    }

    setState(() {
      _currentIndex = index;
    });
    _pageController.jumpToPage(index);

    if (index == 0) { // Switched TO the Featured tab
      final offerProvider = Provider.of<OfferProvider>(context, listen: false);
      offerProvider.loadOffers(category: offerProvider.selectedCategory);
    }
  }

  // This method builds the content FOR the Featured Page.
  // It receives a 'pageContext' from a Builder widget.
  Widget _buildFeaturedPageContent(BuildContext pageContext) {
    // Use pageContext here, which is the build context for this specific page content.
    final offerProvider = Provider.of<OfferProvider>(pageContext); // listen: true is default

    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
          color: Theme.of(pageContext).scaffoldBackgroundColor,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search deals (e.g. Pizza, Spa)',
              hintStyle: TextStyle(color: Colors.grey[500]),
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
              // Other decoration properties will be inherited from the theme
            ),
            onChanged: (value) { /* Implement search logic */ },
          ),
        ),
        Expanded(
          child: offerProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : offerProvider.offers.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'No deals found for "${offerProvider.selectedCategory}".\nSelect a category or check back later!',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => offerProvider.loadOffers(category: offerProvider.selectedCategory),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 4.0, bottom: 70.0),
                        itemCount: offerProvider.offers.length,
                        itemBuilder: (ctx, i) => OfferCard(offer: offerProvider.offers[i]),
                      ),
                    ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define the pages list INSIDE the build method.
    // This ensures that when _buildFeaturedPageContent is part of the list,
    // its eventual call to Provider.of uses a context that is ready.
    final List<Widget> pages = [
      // Wrap the content builder for the featured page in a Builder
      // to get a fresh context when it's actually built by PageView.
      Builder(builder: (pageContext) => _buildFeaturedPageContent(pageContext)),
      const CategoriesScreen(),
      const NotificationsScreen(),
      const SavedScreen(),
      const MyStuffScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIndex == 0 ? 'DealzPark - Featured'
              : _currentIndex == 1 ? 'Categories'
              : _currentIndex == 2 ? 'Notifications'
              : _currentIndex == 3 ? 'Saved Deals'
              : 'My Stuff',
          // style will be inherited from theme
        ),
        // backgroundColor and elevation will be inherited from theme
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_outlined), // color from theme
            tooltip: 'Register Shop',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ShopRegistrationScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        children: pages, // Use the pages list defined above
        onPageChanged: (index) {
          if (_currentIndex != index) {
            setState(() {
              _currentIndex = index;
            });
            // If swiped TO the Featured tab
            if (index == 0) {
              final offerProvider = Provider.of<OfferProvider>(context, listen: false);
              offerProvider.loadOffers(category: offerProvider.selectedCategory);
            }
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        // Other properties will be inherited from theme
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.star_outline),
            activeIcon: Icon(Icons.star),
            label: 'Featured',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view_rounded),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border_outlined),
            activeIcon: Icon(Icons.favorite),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'My Stuff',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => const AddOfferScreen()))
                    .then((value) {
                  if (value == true) { // Offer was successfully added
                    final offerProvider = Provider.of<OfferProvider>(context, listen: false);
                    offerProvider.loadOffers(category: offerProvider.selectedCategory);
                  }
                });
              },
              label: const Text('Add Offer'),
              icon: const Icon(Icons.add),
              // backgroundColor from theme
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}