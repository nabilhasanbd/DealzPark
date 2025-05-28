import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/offer_provider.dart';
import '../widgets/offer_card.dart';
import 'categories_screen.dart';
import 'shop_registration_screen.dart';
import 'add_offer_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text("Notifications")), // This AppBar will still show "Notifications"
    body: const Center(child: Text('Notifications Screen')),
  );
}

class SavedScreen extends StatelessWidget {
  const SavedScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text("Saved Deals")), // This AppBar will still show "Saved Deals"
    body: const Center(child: Text('Saved Deals Screen')),
  );
}

class MyStuffScreen extends StatelessWidget {
  const MyStuffScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text("My Stuff / Profile")), // This AppBar will still show "My Stuff / Profile"
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

  @override
  void initState() {
    super.initState();
    // Initial offer loading is handled by OfferProvider's constructor or didChangeDependencies if needed.
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_currentIndex == index) {
      if (index == 0) { // If featured tab is tapped again, refresh
        final offerProvider = Provider.of<OfferProvider>(context, listen: false);
        offerProvider.loadOffers(category: offerProvider.selectedCategory);
      }
      return;
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

  Widget _buildFeaturedPageContent(BuildContext pageContext) {
    final offerProvider = Provider.of<OfferProvider>(pageContext);

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
    final List<Widget> pages = [
      Builder(builder: (pageContext) => _buildFeaturedPageContent(pageContext)),
      const CategoriesScreen(),
      const NotificationsScreen(),
      const SavedScreen(),
      const MyStuffScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('DealzPark'), // <--- MODIFIED HERE: Always "DealzPark"
        // backgroundColor, elevation, textStyle, iconTheme will be inherited from main.dart's appBarTheme
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_outlined), // color will be inherited
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
        children: pages,
        onPageChanged: (index) {
          if (_currentIndex != index) {
            setState(() {
              _currentIndex = index;
            });
            if (index == 0) { // Swiped TO the Featured tab
              final offerProvider = Provider.of<OfferProvider>(context, listen: false);
              offerProvider.loadOffers(category: offerProvider.selectedCategory);
            }
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        // type, selectedItemColor, unselectedItemColor will be inherited from main.dart's bottomNavigationBarTheme
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
                  if (value == true) {
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