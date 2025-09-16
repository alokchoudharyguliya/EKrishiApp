import 'package:flutter/material.dart';

class NewsCategoriesCard extends StatelessWidget {
  final Map<String, bool> newsCategories;
  final ValueChanged<Map<String, bool>> onChanged;

  const NewsCategoriesCard({
    Key? key,
    required this.newsCategories,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: newsCategories.entries.map((entry) {
          return CheckboxListTile(
            title: Text(
              entry.key,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            value: entry.value,
            onChanged: (bool? value) {
              final updated = Map<String, bool>.from(newsCategories);
              updated[entry.key] = value!;
              onChanged(updated);
            },
            activeColor: Theme.of(context).colorScheme.secondary,
            checkColor: Theme.of(context).colorScheme.onPrimary,
            controlAffinity: ListTileControlAffinity.leading,
          );
        }).toList(),
      ),
    );
  }
}