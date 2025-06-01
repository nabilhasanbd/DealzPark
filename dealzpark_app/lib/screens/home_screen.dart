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
  Widget build(BuildContext context) {
    return Center(child: Text('Notifications'));
  }
}

class SavedScreen extends StatelessWidget {
  const SavedScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Saved'));
  }
}

class MyStuffScreen extends StatelessWidget {
  const MyStuffScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('My Stuff'));
  }
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
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (!mounted) return;
    if (_currentIndex == index) {
      if (index == 0) {
        final offerProvider = Provider.of<OfferProvider>(context, listen: false);
        offerProvider.loadOffers(category: offerProvider.selectedCategoryName);
      }
      return;
    }

    setState(() {
      _currentIndex = index;
    });
    _pageController.jumpToPage(index);

    if (index == 0) {
      final offerProvider = Provider.of<OfferProvider>(context, listen: false);
      offerProvider.loadOffers(category: offerProvider.selectedCategoryName);
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
            ),
            onChanged: (value) {},
          ),
        ),
        Expanded(
          child: offerProvider.isLoadingOffers
              ? const Center(child: CircularProgressIndicator())
              : offerProvider.offers.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'No deals found for "${offerProvider.selectedCategoryName}".\nSelect a category or check back later!',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => offerProvider.loadOffers(category: offerProvider.selectedCategoryName),
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
        title: const Text('DealzPark'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_outlined),
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
          if (!mounted) return;
          if (_currentIndex != index) {
            setState(() {
              _currentIndex = index;
            });
            if (index == 0) {
              final offerProvider = Provider.of<OfferProvider>(context, listen: false);
              offerProvider.loadOffers(category: offerProvider.selectedCategoryName);
            }
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Categories'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'My Stuff'),
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
                    offerProvider.loadOffers(category: offerProvider.selectedCategoryName);
                  }
                });
              },
              label: const Text('Add Offer'),
              icon: const Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
