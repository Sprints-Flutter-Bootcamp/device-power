import 'dart:io';
import 'dart:math';
import 'package:device_power/widgets/my_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class MyGallery extends StatefulWidget {
  const MyGallery({super.key});

  @override
  State<MyGallery> createState() => _MyGalleryState();
}

class _MyGalleryState extends State<MyGallery> {
  List<File> _images = []; // List of stored images

  @override
  void initState() {
    super.initState();
    requestPermissions();
    loadImages();
  }

  // Request permissions for camera and gallery
  Future<void> requestPermissions() async {
    await Permission.camera.request();
    await Permission.photos.request();
  }

  // Load saved images from SharedPreferences
  Future<void> loadImages() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedPaths = prefs.getStringList("gallery_images");

    if (savedPaths != null) {
      setState(() {
        _images = savedPaths
            .where(
                (path) => File(path).existsSync()) // Filter non-existent files
            .map((path) => File(path))
            .toList();
      });
    }
  }

// Gallery functions ----------------------------------------------------------
  Future<void> saveImages() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> paths = _images.map((file) => file.path).toList();
    await prefs.setStringList("gallery_images", paths);
  }

  Future<String> saveToAppDirectory(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath =
        '${directory.path}/gallery_image_${Random().nextInt(10000)}.png';
    final newImage = await imageFile.copy(imagePath);
    return newImage.path;
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile == null) return;

      File tempImage = File(pickedFile.path);
      String newPath = await saveToAppDirectory(tempImage);

      setState(() {
        _images.add(File(newPath));
      });

      saveImages();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error picking image: $e")),
        );
      }
    }
  }

  void removeImage(int index) async {
    setState(() {
      _images.removeAt(index);
    });
    saveImages();
  }
  // --------------------------------------------------------------------------

  void showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from Gallery"),
              onTap: () {
                pickImage(ImageSource.gallery);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text("Take a Photo"),
              onTap: () {
                pickImage(ImageSource.camera);
                Navigator.pop(context);
              },
            ),
            if (_images.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text("Clear All"),
                onTap: () {
                  setState(() {
                    _images.clear();
                  });
                  saveImages();
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(context, "My Gallery"),
      body: _images.isEmpty
          ? const Center(child: Text("Let's save memories to your gallery!"))
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _images.length,
                itemBuilder: (context, index) => Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_images[index], fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: GestureDetector(
                        onTap: () => removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.delete_outline,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: showImagePicker,
        child: const Icon(Icons.add_a_photo, color: Colors.white),
      ),
    );
  }
}
