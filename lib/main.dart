import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ImageSelector(),
    );
  }
}

class ImageSelector extends StatefulWidget {
  const ImageSelector({Key? key}) : super(key: key);

  @override
  ImageSelectorState createState() => ImageSelectorState();
}

class ImageSelectorState extends State<ImageSelector> {
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadImageFromPrefs(); // Load previously selected image if available
  }

  Future<void> _selectImage() async {
    setState(() {
      _imageFile = null;
    });

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      await _saveImageToPrefs(pickedFile.path);
      await _loadImageFromPrefs(); // Reload the image from prefs
    }
  }

  Future<void> _saveImageToPrefs(String path) async {
    final directory = await getApplicationDocumentsDirectory();
    final prefsFile = File('${directory.path}/image_path.txt');
    await prefsFile.writeAsString(path);
  }

  Future<void> _loadImageFromPrefs() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final prefsFile = File('${directory.path}/image_path.txt');

      if (prefsFile.existsSync()) {
        final String path = prefsFile.readAsStringSync();

        // Check if the path is not empty before setting the state
        if (path.isNotEmpty) {
          setState(() {
            _imageFile = File(path);
          });
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error loading image from prefs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(25.0),
                child: Image.asset(
                  'assets/c3lf.jpg',
                  width: 40.0,
                  height: 40.0,
                )),
            const SizedBox(width: 10),
            const Text('QR Code Displayer'),
          ],
        ),
      ),
      body: Center(
        child: _imageFile == null
            ? const Text('No QR selected.')
            : Image.file(
                _imageFile!,
                width: 400.0,
                height: 400.0,
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _selectImage,
        tooltip: 'Select Image',
        child: const Icon(Icons.qr_code_2_outlined),
      ),
    );
  }
}
