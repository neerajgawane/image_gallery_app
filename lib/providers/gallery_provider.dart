import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as img;
import '../models/image_item.dart';

class GalleryProvider with ChangeNotifier {
  List<ImageItem> _images = [];
  bool _isLoading = true;
  final _picker = ImagePicker();
  static const int maxImageSize = 1920; // Changed to int
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB in bytes
  
  // Getters
  List<ImageItem> get images => [..._images];
  bool get isLoading => _isLoading;
  int get totalImages => _images.length;
  int get localImages => _images.where((img) => !img.isAsset).length;
  int get assetImages => _images.where((img) => img.isAsset).length;

  // Constructor
  GalleryProvider() {
    _loadImages();
  }

  // Sort Methods
  void sortByDate() {
    _images.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    notifyListeners();
  }

  void sortByTitle() {
    _images.sort((a, b) => a.title.compareTo(b.title));
    notifyListeners();
  }

  // Filter Methods
  List<ImageItem> filterByTag(String tag) {
    return _images.where((img) => img.tags.contains(tag)).toList();
  }

  // Load Images
  Future<void> _loadImages() async {
    try {
      // Load initial asset images
      _images = [
        ImageItem(
          id: '1',
          path: 'assets/images/image1.jpg',
          title: 'Mountain View',
          description: 'Beautiful mountain landscape view.',
          tags: ['nature', 'landscape'],
        ),
        ImageItem(
          id: '2',
          path: 'assets/images/image2.jpg',
          title: 'Sunset Beach',
          description: 'Stunning sunset at the beach.',
          tags: ['beach', 'sunset'],
        ),
        ImageItem(
          id: '3',
          path: 'assets/images/image3.jpg',
          title: 'Athlete',
          description: 'A sprinter launching off the starting blocks with intense focus and explosive power.',
          tags: ['sports', 'action'],
        ),
        ImageItem(
          id: '4',
          path: 'assets/images/image4.jpg',
          title: 'Football Player',
          description: 'A football player in action, showcasing agility and precision.',
          tags: ['sports', 'football'],
        ),
      ];

      // Verify assets exist
      for (var image in _images.where((img) => img.isAsset).toList()) {
        try {
          await rootBundle.load(image.path);
        } catch (e) {
          debugPrint('Asset not found: ${image.path}');
          _images.remove(image);
        }
      }

      // Setup local storage
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // Load saved images
      final file = File('${directory.path}/gallery_data.json');
      if (await file.exists()) {
        try {
          final jsonString = await file.readAsString();
          final List<dynamic> jsonList = json.decode(jsonString);
          final savedImages = jsonList
              .map((json) => ImageItem.fromJson(json))
              .where((image) => !image.isAsset)
              .toList();

          // Verify saved images exist
          for (var image in savedImages) {
            final imageFile = File(image.path);
            if (await imageFile.exists()) {
              _images.add(image);
            } else {
              debugPrint('Local image not found: ${image.path}');
            }
          }
        } catch (e) {
          debugPrint('Error parsing saved images: $e');
        }
      }

      sortByDate(); // Default sort
    } catch (e) {
      debugPrint('Error loading images: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save to Storage
  Future<void> _saveToStorage() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/gallery_data.json');
      
      // Only save non-asset images
      final imagesToSave = _images.where((image) => !image.isAsset).toList();
      final jsonString = json.encode(
        imagesToSave.map((image) => image.toJson()).toList(),
      );
      
      await file.writeAsString(jsonString);
    } catch (e) {
      debugPrint('Error saving images: $e');
      rethrow;
    }
  }

  // Add Image
  Future<void> addImage(String title, String description, List<String> tags) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: maxImageSize.toDouble(),
        maxHeight: maxImageSize.toDouble(),
      );

      if (pickedFile == null) {
        throw Exception('No image selected');
      }

      // Validate file size
      final file = File(pickedFile.path);
      final fileSize = await file.length();
      if (fileSize > maxFileSize) {
        throw Exception('Image size too large. Please select an image under 10MB.');
      }

      // Validate file type
      final String extension = pickedFile.path.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png'].contains(extension)) {
        throw Exception('Unsupported file type. Please use JPG or PNG images.');
      }

      // Process and save image
      final directory = await getApplicationDocumentsDirectory();
      final String id = const Uuid().v4();
      final String newPath = '${directory.path}/images/$id.$extension';

      // Compress and save image
      final imageBytes = await file.readAsBytes();
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception('Failed to process image');
      }

      // Resize if needed
      final processedImage = img.copyResize(
        image,
        width: image.width > maxImageSize ? maxImageSize : image.width,
        height: image.height > maxImageSize ? maxImageSize : image.height,
      );

      // Encode and save
      final compressedBytes = extension == 'png' 
          ? img.encodePng(processedImage) 
          : img.encodeJpg(processedImage, quality: 85);

      await File(newPath).writeAsBytes(compressedBytes);

      // Create new image item
      final newImage = ImageItem(
        id: id,
        path: newPath,
        title: title,
        description: description,
        isAsset: false,
        tags: tags,
        dateAdded: DateTime.now(),
      );

      _images.add(newImage);
      await _saveToStorage();
      sortByDate();
      notifyListeners();

    } catch (e) {
      debugPrint('Error adding image: $e');
      rethrow;
    }
  }

  // Delete Image
  Future<void> deleteImage(String id) async {
    try {
      final image = _images.firstWhere((img) => img.id == id);
      if (!image.isAsset) {
        final file = File(image.path);
        if (await file.exists()) {
          await file.delete();
        }
      }
      _images.removeWhere((img) => img.id == id);
      await _saveToStorage();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting image: $e');
      rethrow;
    }
  }

  // Update Image
  Future<void> updateImage(String id, {String? title, String? description, List<String>? tags}) async {
    try {
      final index = _images.indexWhere((img) => img.id == id);
      if (index != -1) {
        final image = _images[index];
        _images[index] = ImageItem(
          id: image.id,
          path: image.path,
          title: title ?? image.title,
          description: description ?? image.description,
          dateAdded: image.dateAdded,
          isAsset: image.isAsset,
          tags: tags ?? image.tags,
        );
        await _saveToStorage();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating image: $e');
      rethrow;
    }
  }

  // Refresh Images
  Future<void> refreshImages() async {
    _isLoading = true;
    notifyListeners();
    await _loadImages();
  }

  // Get Storage Info
  Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/images');
      int totalSize = 0;

      if (await imagesDir.exists()) {
        await for (var entity in imagesDir.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }

      return {
        'totalImages': totalImages,
        'localImages': localImages,
        'assetImages': assetImages,
        'totalSize': totalSize,
        'path': imagesDir.path,
      };
    } catch (e) {
      debugPrint('Error getting storage info: $e');
      rethrow;
    }
  }

  // Check Image Status
  Future<Map<String, dynamic>> checkImageStatus(String id) async {
    try {
      final image = _images.firstWhere((img) => img.id == id);
      final status = {
        'exists': false,
        'size': 0,
        'path': image.path,
        'isAsset': image.isAsset,
        'dateAdded': image.dateAdded.toIso8601String(),
        'tags': image.tags,
      };

      if (image.isAsset) {
        try {
          final asset = await rootBundle.load(image.path);
          status['exists'] = true;
          status['size'] = asset.lengthInBytes;
        } catch (e) {
          status['error'] = 'Asset not found: $e';
        }
      } else {
        final file = File(image.path);
        status['exists'] = await file.exists();
        if (status['exists'] == true) {
          status['size'] = await file.length();
        }
      }

      return status;
    } catch (e) {
      return {
        'error': 'Image not found in gallery',
        'details': e.toString(),
      };
    }
  }
}