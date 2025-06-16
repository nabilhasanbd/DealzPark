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
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      clipBehavior: Clip.antiAlias, // Important for rounded corners on Stack children
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: isExpired
            ? null
            : () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => OfferDetailScreen(offer: offer),
                  ),
                );
              },
        child: Opacity(
          opacity: isExpired ? 0.6 : 1.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Stack(
                children: [
                  // --- Image ---
                  AspectRatio(
                    aspectRatio: 20 / 9,
                    child: (offer.promotionalImageUrl != null &&
                            offer.promotionalImageUrl!.isNotEmpty)
                        ? Image.network(
                            offer.promotionalImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Center(
                                    child: Icon(Icons.broken_image,
                                        size: 40, color: Colors.grey)),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Text('Image Not Available',
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                ),
                            ),
                            ),
                          ),
                  ),
                  // --- Discount Badge ---
                  if (offer.discountPercentage > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error, // Use error color for discount
                          borderRadius: BorderRadius.circular(16),
                           boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: Offset(0, 1),
                            )
                          ]
                        ),
                        child: Text(
                          '${offer.discountPercentage}% OFF',
                          style: textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Shop Name & Category (Optional) ---
                    Text(
                      offer.shopName.toUpperCase(),
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // --- Promotional Title ---
                    Text(
                      offer.promotionalTitle,
                      style: textTheme.titleSmall?.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // --- Validity & "Bought" count (Placeholder for bought) ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isExpired
                              ? 'Expired: ${formatter.format(offer.validTo.toLocal())}'
                              : 'Ends: ${formatter.format(offer.validTo.toLocal())}',
                          style: textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              color: isExpired
                                  ? Colors.red.shade700
                                  : Colors.green.shade700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // --- Price Info (Placeholder) & Details Button ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end, // Align button to the right
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            textStyle: const TextStyle(fontWeight: FontWeight.bold)
                          ),
                          onPressed: isExpired ? null : () {
                             Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => OfferDetailScreen(offer: offer),
                                ),
                              );
                          },
                          child: const Text('View Deal'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}