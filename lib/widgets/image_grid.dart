import 'package:flutter/material.dart';
import 'package:image_gallery_app/screens/image_details_screen';
import 'package:provider/provider.dart';
import '../providers/gallery_provider.dart';
import 'image_grid_item.dart';

class ImageGrid extends StatelessWidget {
  const ImageGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GalleryProvider>(
      builder: (context, galleryData, child) {
        final images = galleryData.images;

        if (images.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.photo_library_outlined, size: 64),
                const SizedBox(height: 16),
                Text(
                  'No images available',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Add images using the + button below',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: images.length,
          itemBuilder: (ctx, i) => ImageGridItem(
            image: images[i],
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ImageDetailsScreen(image: images[i]),
                ),
              );
            },
          ),
        );
      },
    );
  }
}