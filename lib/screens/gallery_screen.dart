import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gallery_provider.dart';
import '../widgets/image_grid.dart';
import '../widgets/add_image_dialog.dart';
import '../widgets/storage_info_dialog.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  void _addNewImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const AddImageDialog(),
    );
  }

  void _showStorageInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const StorageInfoDialog(),
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Sort by Date'),
            onTap: () {
              Provider.of<GalleryProvider>(context, listen: false).sortByDate();
              Navigator.pop(ctx);
            },
          ),
          ListTile(
            leading: const Icon(Icons.sort_by_alpha),
            title: const Text('Sort by Title'),
            onTap: () {
              Provider.of<GalleryProvider>(context, listen: false).sortByTitle();
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Image Gallery',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortOptions(context),
            tooltip: 'Sort Images',
          ),
          IconButton(
            icon: const Icon(Icons.storage),
            onPressed: () => _showStorageInfo(context),
            tooltip: 'Storage Info',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => Provider.of<GalleryProvider>(
          context,
          listen: false,
        ).refreshImages(),
        child: Consumer<GalleryProvider>(
          builder: (context, galleryProvider, child) {
            if (galleryProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return const ImageGrid();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewImage(context),
        child: const Icon(Icons.add_photo_alternate),
      ),
    );
  }
}