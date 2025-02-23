import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/gallery_screen.dart';
import 'providers/gallery_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GalleryProvider(),
      child: MaterialApp(
        title: 'Image Gallery',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const GalleryScreen(),
      ),
    );
  }
}
