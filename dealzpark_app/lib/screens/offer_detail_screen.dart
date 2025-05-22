import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/offer.dart';

class OfferDetailScreen extends StatelessWidget {
  final Offer offer;

  const OfferDetailScreen({Key? key, required this.offer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('MMM dd, yyyy HH:mm');
    final bool isExpired = DateTime.now().isAfter(offer.validTo);

    return Scaffold(
      appBar: AppBar(
        title: Text(offer.promotionalTitle, style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (offer.promotionalImageUrl != null && offer.promotionalImageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  offer.promotionalImageUrl!,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 250,
                    color: Colors.grey[300],
                    child: const Center(child: Icon(Icons.broken_image, size: 60, color: Colors.grey)),
                  ),
                ),
              )
            else
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: const Center(
                  child: Text('Promotional Image Not Available', style: TextStyle(color: Colors.grey)),
                ),
              ),
            const SizedBox(height: 20),
            Text(
              offer.promotionalTitle,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (offer.discountPercentage > 0)
              Text(
                '${offer.discountPercentage}% OFF',
                style: const TextStyle(fontSize: 20, color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 10),
            Text(
              'Offered by: ${offer.shopName}',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey[700]),
            ),
            const SizedBox(height: 5),
            Text(
              'Category: ${offer.category}',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 15),
            const Divider(),
            const SizedBox(height: 15),
            Text(
              isExpired ? 'Expired on: ${formatter.format(offer.validTo.toLocal())}' : 'Valid: ${formatter.format(offer.validFrom.toLocal())} - ${formatter.format(offer.validTo.toLocal())}',
              style: TextStyle(fontSize: 14, color: isExpired ? Colors.red : Colors.green[700]),
            ),
            const SizedBox(height: 10),
            Text(
              'Posted on: ${formatter.format(offer.createdAt.toLocal())}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            if (offer.productImageUrl != null && offer.productImageUrl!.isNotEmpty) ...[
              const Text('Product Image:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
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
                    child: const Center(child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey)),
                  ),
                ),
              ),
            ] else ... [
                 const Text('Product Image:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                 const SizedBox(height: 10),
                 Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: const Center(
                      child: Text('Product Image Not Available', style: TextStyle(color: Colors.grey)),
                    ),
                  )
            ],
            const SizedBox(height: 30),
            if (!isExpired)
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('Avail Deal (Placeholder)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  onPressed: () {
                    // Placeholder for navigating to the deal, e.g., open a web link
                     ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Link to deal would open here!')),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}