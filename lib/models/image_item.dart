class ImageItem {
  final String id;
  final String path;
  final String title;
  final String description;
  final DateTime dateAdded;
  final bool isAsset;
  final List<String> tags; 

  ImageItem({
    required this.id,
    required this.path,
    required this.title,
    required this.description,
    DateTime? dateAdded,
    this.isAsset = true,
    List<String>? tags, // Make tags optional
  }) : dateAdded = dateAdded ?? DateTime.now(),
       tags = tags ?? []; 

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'path': path,
      'title': title,
      'description': description,
      'dateAdded': dateAdded.toIso8601String(),
      'isAsset': isAsset,
      'tags': tags,
    };
  }

  factory ImageItem.fromJson(Map<String, dynamic> json) {
    return ImageItem(
      id: json['id'],
      path: json['path'],
      title: json['title'],
      description: json['description'],
      dateAdded: DateTime.parse(json['dateAdded']),
      isAsset: json['isAsset'] ?? true,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}