import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationPopup extends StatelessWidget {
  final String title;
  final String? description;
  final DateTime eventTime;
  final String? activityType;
  final String? cropType;
  final String? fieldLocation;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const NotificationPopup({
    Key? key,
    required this.title,
    this.description,
    required this.eventTime,
    this.activityType,
    this.cropType,
    this.fieldLocation,
    this.onTap,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and dismiss button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.notifications_active,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onDismiss != null)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: onDismiss,
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Activity Type Badge
              if (activityType != null) ...[
                Chip(
                  label: Text(
                    activityType!,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                const SizedBox(height: 8),
              ],
              
              // Description
              if (description != null && description!.isNotEmpty) ...[
                Text(
                  description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
              ],
              
              // Event Details
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  if (cropType != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.grass,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          cropType!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  if (fieldLocation != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          fieldLocation!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Event Time
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Event: ${DateFormat('MMM dd, yyyy - hh:mm a').format(eventTime)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: onDismiss,
                    child: const Text('Dismiss'),
                  ),
                  if (onTap != null) ...[
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: onTap,
                      child: const Text('View Event'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper widget to show notification popup as overlay
class NotificationOverlay {
  static OverlayEntry? _overlayEntry;

  static void show({
    required BuildContext context,
    required String title,
    String? description,
    required DateTime eventTime,
    String? activityType,
    String? cropType,
    String? fieldLocation,
    VoidCallback? onTap,
    VoidCallback? onDismiss,
    Duration duration = const Duration(seconds: 5),
  }) {
    // Remove existing overlay if any
    dismiss();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 8,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: NotificationPopup(
            title: title,
            description: description,
            eventTime: eventTime,
            activityType: activityType,
            cropType: cropType,
            fieldLocation: fieldLocation,
            onTap: () {
              if (onTap != null) {
                onTap();
                dismiss();
              }
            },
            onDismiss: () {
              if (onDismiss != null) {
                onDismiss();
              }
              dismiss();
            },
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    // Auto-dismiss after duration
    if (duration.inSeconds > 0) {
      Future.delayed(duration, () {
        dismiss();
      });
    }
  }

  static void dismiss() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

