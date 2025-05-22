import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/offer.dart';
import '../screens/offer_detail_screen.dart';

class OfferCard extends StatelessWidget {
  final Offer offer;

  const OfferCard({Key? key, required this.offer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('MMM dd, yyyy');
    final bool isExpired = DateTime.now().isAfter(offer.validTo);

    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Opacity(
        opacity: isExpired ? 0.5 : 1.0,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    offer.shopName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  if (offer.discountPercentage > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${offer.discountPercentage}% OFF',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (offer.promotionalImageUrl != null && offer.promotionalImageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    offer.promotionalImageUrl!, // Assuming full URL from API
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        color: Colors.grey[300],
                        child: const Center(child: Icon(Icons.image_not_supported, size: 50)),
                      );
                    },
                  ),
                )
              else
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Center(
                    child: Text('Image Not Available', style: TextStyle(color: Colors.grey)),
                  ),
                ),
              const SizedBox(height: 12),
              Text(
                offer.promotionalTitle,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                isExpired ? 'Expired on: ${formatter.format(offer.validTo.toLocal())}' : 'Valid until: ${formatter.format(offer.validTo.toLocal())}',
                style: TextStyle(fontSize: 12, color: isExpired ? Colors.red : Colors.grey[600]),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Details'),
                  onPressed: isExpired ? null : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => OfferDetailScreen(offer: offer),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}