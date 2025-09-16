import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResetButton extends StatelessWidget {
  final VoidCallback? onReset;
  final Map<String, bool>? newsCategories;
  final VoidCallback? onCategoriesReset;

  const ResetButton({
    Key? key,
    this.onReset,
    this.newsCategories,
    this.onCategoriesReset,
  }) : super(key: key);

  Future<void> _showResetDialog(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          title: Text(
            'Reset Settings',
            style: TextStyle(color: colorScheme.onSurface),
          ),
          content: Text(
            'Are you sure you want to reset all settings to default?',
            style: TextStyle(color: colorScheme.onSurface),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: colorScheme.secondary),
              ),
            ),
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                if (newsCategories != null && onCategoriesReset != null) {
                  newsCategories!.updateAll((key, value) => true);
                  onCategoriesReset!();
                }
                if (onReset != null) onReset!();
                Navigator.of(context).pop();
              },
              child: Text(
                'Reset',
                style: TextStyle(color: colorScheme.secondary),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.secondary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        onPressed: () => _showResetDialog(context),
        child: const Text('Reset to Default'),
      ),
    );
  }
}
