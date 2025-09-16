import 'package:flutter/material.dart';

class FontSizeSelector extends StatelessWidget {
  final String selectedFontSize;
  final ValueChanged<String> onChanged;

  const FontSizeSelector({
    Key? key,
    required this.selectedFontSize,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Theme.of(context).colorScheme.surface,
      child: ListTile(
        title: Text(
          'Font Size',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        trailing: DropdownButton<String>(
          value: selectedFontSize,
          dropdownColor: Theme.of(context).colorScheme.surface,
          onChanged: (String? newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
          items:
              [
                'Small',
                'Medium',
                'Large',
                'Extra Large',
              ].map<DropdownMenuItem<String>>((String value) {
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
