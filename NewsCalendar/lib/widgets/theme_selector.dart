import 'package:flutter/material.dart';

class ThemeSelector extends StatelessWidget {
  final String selectedTheme;
  final ValueChanged<String> onChanged;

  const ThemeSelector({
    Key? key,
    required this.selectedTheme,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Theme.of(context).colorScheme.surface,
      child: ListTile(
        title: Text(
          'App Theme',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        trailing: DropdownButton<String>(
          value: selectedTheme,
          dropdownColor: Theme.of(context).colorScheme.surface,
          onChanged: (String? newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
          items:
              ['Light', 'Dark'].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}
