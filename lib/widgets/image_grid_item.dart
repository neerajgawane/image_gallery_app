import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_gallery_app/widgets/image_debug_dialog.dart';
import '../models/image_item.dart';

class ImageGridItem extends StatelessWidget {
  final ImageItem image;
  final VoidCallback onTap;

  const ImageGridItem({
    super.key,
    required this.image,
    required this.onTap,
  });

 @override
Widget build(BuildContext context) {
  return GestureDetector(
    onTap: onTap,
    onLongPress: () {
      showDialog(
        context: context,
        builder: (ctx) => ImageDebugDialog(image: image),
      );
    },
    child: Hero(
      tag: image.id,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: image.isAsset
              ? Image.asset(
                  image.path,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('Error loading asset image: $error');
                    return const Center(
                      child: Icon(Icons.error_outline, color: Colors.red),
                    );
                  },
                )
              : Image.file(
                  File(image.path),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('Error loading local image: $error');
                    return const Center(
                      child: Icon(Icons.error_outline, color: Colors.red),
                    );
                  },
                ),
        ),
      ),
    ),
  );
}
}