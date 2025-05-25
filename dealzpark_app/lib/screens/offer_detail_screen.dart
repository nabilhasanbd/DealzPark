import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/offer.dart';

class OfferDetailScreen extends StatelessWidget {
  final Offer offer;

  const OfferDetailScreen({Key? key, required this.offer}) : super(key: key);

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 20),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 15, color: valueColor ?? Colors.black87),
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('MMMM dd, yyyy');
    final bool isExpired = DateTime.now().isAfter(offer.validTo);

    return Scaffold(
      // appBar: AppBar( // Can be removed if using SliverAppBar below
      //   title: Text(offer.promotionalTitle, style: TextStyle(color: Colors.white)),
      //   backgroundColor: Theme.of(context).primaryColor,
      //   iconTheme: IconThemeData(color: Colors.white),
      // ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            iconTheme: const IconThemeData(color: Colors.white),
            backgroundColor: Theme.of(context).primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                offer.promotionalTitle,
                style: const TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: (offer.promotionalImageUrl != null &&
                      offer.promotionalImageUrl!.isNotEmpty)
                  ? Image.network(
                      offer.promotionalImageUrl!,
                      fit: BoxFit.cover,
                      color: Colors.black.withOpacity(0.3), // Darken image slightly for text readability
                      colorBlendMode: BlendMode.darken,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[400],
                        child: const Center(
                            child: Icon(Icons.broken_image,
                                size: 60, color: Colors.white70)),
                      ),
                    )
                  : Container(
                      color: Colors.grey[400],
                      child: const Center(
                          child: Icon(Icons.image_not_supported,
                              size: 60, color: Colors.white70)),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    offer.promotionalTitle,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (offer.discountPercentage > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        '${offer.discountPercentage}% OFF',
                        style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Card( // Grouping info in a card
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                           _buildInfoRow(context, Icons.storefront_outlined, 'Offered by', offer.shopName),
                           _buildInfoRow(context, Icons.category_outlined, 'Category', offer.category),
                           _buildInfoRow(
                            context,
                            Icons.calendar_today_outlined,
                            isExpired ? 'Expired On' : 'Valid Until',
                            formatter.format(offer.validTo.toLocal()),
                            valueColor: isExpired ? Colors.red.shade700 : Colors.green.shade700,
                          ),
                           if (!isExpired)
                            _buildInfoRow(context, Icons.calendar_view_day_outlined, 'Valid From', formatter.format(offer.validFrom.toLocal())),
                           _buildInfoRow(context, Icons.access_time_outlined, 'Posted On', DateFormat('MMMM dd, yyyy HH:mm').format(offer.createdAt.toLocal())),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  if (offer.productImageUrl != null &&
                      offer.productImageUrl!.isNotEmpty) ...[
                    Text('Product Image:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        offer.productImageUrl!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Center(
                              child: Icon(Icons.image_not_supported,
                                  size: 60, color: Colors.grey)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Placeholder for "What You Get", "The Fine Print" sections
                  // You would add Text widgets or custom widgets for these
                  // Text("What You Get:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  // SizedBox(height: 8),
                  // Text("Detailed description of the offer benefits..."),
                  // SizedBox(height: 16),
                  // Text("The Fine Print:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  // SizedBox(height: 8),
                  // Text("Terms and conditions, restrictions..."),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: isExpired
          ? null
          : Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.shopping_cart_checkout_outlined),
                label: const Text('GET DEAL'), // Groupon often uses "Buy Now" or similar
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  minimumSize: const Size(double.infinity, 50), // Full width
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Link to deal would open here!')),
                  );
                },
              ),
            ),
    );
  }
}