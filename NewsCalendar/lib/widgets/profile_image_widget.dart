import 'dart:io';
import 'package:flutter/material.dart';

class ProfileImageWidget extends StatelessWidget {
  final File? selectedImageFile;
  final File? cachedImageFile;
  final String? photoUrl;

  const ProfileImageWidget({
    Key? key,
    this.selectedImageFile,
    this.cachedImageFile,
    this.photoUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget imageWidget;
    if (selectedImageFile != null) {
      imageWidget = Image.file(
        selectedImageFile!,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      );
    } else if (cachedImageFile != null) {
      imageWidget = Image.file(
        cachedImageFile!,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      );
    } else if (photoUrl == null) {
      imageWidget = Container(
        color: colorScheme.surfaceVariant,
        child: Icon(
          Icons.person,
          size: 60,
          color: colorScheme.onSurfaceVariant,
        ),
      );
    } else {
      imageWidget = Image.network(
        photoUrl!,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value:
                  loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
              color: colorScheme.primary,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: colorScheme.surfaceVariant,
            child: Icon(
              Icons.person,
              size: 60,
              color: colorScheme.onSurfaceVariant,
            ),
          );
        },
      );
    }

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: ClipOval(child: imageWidget),
    );
  }
}
