import 'package:flutter/material.dart';

class EditableField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isEditing;
  final TextInputType? keyboardType;
  final bool isDateField;
  final VoidCallback? onDateTap;

  const EditableField({
    Key? key,
    required this.label,
    required this.controller,
    required this.isEditing,
    this.keyboardType,
    this.isDateField = false,
    this.onDateTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isEditing)
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          isEditing
              ? isDateField
                  ? InkWell(
                    onTap: onDateTap,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceVariant,
                        suffixIcon: Icon(
                          Icons.calendar_today,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      child: Text(
                        controller.text.isNotEmpty
                            ? controller.text
                            : 'Select date',
                        style: textTheme.bodyLarge?.copyWith(
                          color:
                              controller.text.isNotEmpty
                                  ? colorScheme.onSurface
                                  : colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ),
                  )
                  : TextFormField(
                    controller: controller,
                    keyboardType: keyboardType,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: colorScheme.outline),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceVariant,
                    ),
                    validator: (value) {
                      if (label == 'Phone' && value!.isNotEmpty) {
                        if (value.length < 10) {
                          return 'Phone number must be at least 10 digits';
                        }
                        if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                          return 'Only digits are allowed';
                        }
                      }
                      if (label == 'Email' && value!.isNotEmpty) {
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Enter a valid email address';
                        }
                      }
                      return null;
                    },
                  )
              : Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$label: ',
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        controller.text.isNotEmpty
                            ? controller.text
                            : 'Not provided',
                        style: textTheme.bodyLarge?.copyWith(
                          color:
                              controller.text.isNotEmpty
                                  ? colorScheme.onSurface
                                  : colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
