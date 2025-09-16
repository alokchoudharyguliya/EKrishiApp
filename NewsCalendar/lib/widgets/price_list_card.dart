import 'package:flutter/material.dart';

class PriceListCard extends StatelessWidget {
  final Map<String, String> cropPrices; // e.g. {'Wheat': '₹2200/qtl', ...}
  final String? mandiName;
  final String? date;

  const PriceListCard({
    Key? key,
    required this.cropPrices,
    this.mandiName,
    this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (mandiName != null || date != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (mandiName != null)
                    Text(
                      mandiName!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                        fontSize: 16,
                      ),
                    ),
                  if (date != null)
                    Text(
                      date!,
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            if (mandiName != null || date != null) const SizedBox(height: 10),
            ...cropPrices.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 15,
                        color: colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
