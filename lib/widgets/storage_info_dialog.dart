import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../providers/gallery_provider.dart';

class StorageInfoDialog extends StatelessWidget {
  const StorageInfoDialog({super.key});

  Future<String> _getStoragePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/images';
  }

  Future<String> _getStorageSize() async {
    final directory = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${directory.path}/images');
    
    if (!await imagesDir.exists()) return '0 KB';
    
    int totalSize = 0;
    await for (var entity in imagesDir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        totalSize += await entity.length();
      }
    }
    
    if (totalSize < 1024) return '$totalSize B';
    if (totalSize < 1024 * 1024) return '${(totalSize / 1024).toStringAsFixed(2)} KB';
    return '${(totalSize / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: Future.wait([_getStoragePath(), _getStorageSize()]),
      builder: (context, snapshot) {
        return AlertDialog(
          title: const Text('Storage Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Storage Location:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(snapshot.data?[0] ?? 'Loading...'),
              const SizedBox(height: 16),
              const Text(
                'Storage Usage:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(snapshot.data?[1] ?? 'Calculating...'),
              const SizedBox(height: 16),
              Consumer<GalleryProvider>(
                builder: (context, provider, child) {
                  final localImages = provider.images.where((img) => !img.isAsset).length;
                  final assetImages = provider.images.where((img) => img.isAsset).length;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Local Images: $localImages'),
                      Text('Asset Images: $assetImages'),
                      Text('Total Images: ${provider.images.length}'),
                    ],
                  );
                },
              ),
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
