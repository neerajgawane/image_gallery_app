import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gallery_provider.dart';
import '../models/image_item.dart';

class ImageDebugDialog extends StatelessWidget {
  final ImageItem image;

  const ImageDebugDialog({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: Provider.of<GalleryProvider>(context, listen: false)
          .checkImageStatus(image.id),
      builder: (context, snapshot) {
        return AlertDialog(
          title: const Text('Image Debug Info'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Image ID: ${image.id}'),
              Text('Path: ${image.path}'),
              Text('Is Asset: ${image.isAsset}'),
              Text('Status: ${snapshot.hasData ? "Loaded" : "Loading..."}'),
              if (snapshot.hasData) ...[
                Text('Exists: ${snapshot.data!['exists']}'),
                Text('Size: ${snapshot.data!['size']} bytes'),
                if (snapshot.data!.containsKey('error'))
                  Text('Error: ${snapshot.data!['error']}',
                      style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
