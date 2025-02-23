# Image Gallery App

A Flutter application that allows users to view, add, and share images with a clean and simple interface.

## Features

- Display images in a responsive grid layout
- View image details including title and description
- Add new images from device gallery
- Share images with other apps
- Support for both asset and local storage images
- Storage information tracking
- Debug information for troubleshooting

## Getting Started

### Prerequisites

- Flutter SDK (Latest stable version)
- Dart SDK (Latest stable version)
- Android Studio / VS Code with Flutter extensions

### Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  provider: ^6.1.2
  share_plus: ^10.1.4
  path_provider: ^2.1.5
  image_picker: ^1.1.2
  ulid: ^2.0.1
  image: ^4.5.3
```

### Installation

1. Clone the repository:

```bash
git clone https://github.com/neerajgawane/image_gallery_app.git
```

2. Navigate to project directory:

```bash
cd image_gallery_app
```

3. Install dependencies:

```bash
flutter pub get
```

4. Run the app:

```bash
flutter run
```

## Project Structure

```
lib/
  ├── main.dart
  ├── models/
  │   └── image_item.dart
  ├── providers/
  │   └── gallery_provider.dart
  ├── screens/
  │   ├── gallery_screen.dart
  │   └── image_details_screen.dart
  └── widgets/
      ├── add_image_dialog.dart
      ├── image_debug_dialog.dart
      ├── image_grid.dart
      ├── image_grid_item.dart
      └── storage_info_dialog.dart
```

## Implementation Details

- Uses Provider pattern for state management
- Implements local storage for persisting image data
- Handles both asset and local file system images
- Includes debug functionality for troubleshooting
- Implements proper error handling and loading states

## Testing

To run the tests:

```bash
flutter test
```

## Known Issues

- None currently reported

## Future Improvements

- Add image editing capabilities
- Implement image categorization
- Add search functionality
- Support for cloud storage
- Add user authentication

## Support

For support, email neerajsgawane@gmail.com or create an issue in the repository.
