import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:mime/mime.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_animate/flutter_animate.dart';

class IdentificationPage extends StatefulWidget {
  @override
  _IdentificationPageState createState() => _IdentificationPageState();
}

class _IdentificationPageState extends State<IdentificationPage>
    with TickerProviderStateMixin {
  File? _image;
  String? _species;
  String? _gender;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File resizedImage = await _resizeImage(File(pickedFile.path));

      setState(() {
        _image = resizedImage;
        _species = null;
        _gender = null;
      });

      _uploadImage(_image!);
    }
  }

  Future<File> _resizeImage(File originalImage) async {
    final rawBytes = await originalImage.readAsBytes();
    final image = img.decodeImage(rawBytes);

    if (image == null) throw Exception("Failed to decode image");

    final resized = img.copyResize(image, width: 224, height: 224);

    final tempDir = Directory.systemTemp;
    final resizedPath =
        '${tempDir.path}/resized_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final resizedFile =
        File(resizedPath)..writeAsBytesSync(img.encodeJpg(resized));

    return resizedFile;
  }

  Future<void> _uploadImage(File imageFile) async {
    setState(() {
      _isLoading = true;
    });

    final mimeTypeData = lookupMimeType(imageFile.path)?.split('/');
    final request = http.MultipartRequest(
        'POST', Uri.parse('http://192.168.0.109:8000/predict/'));
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      imageFile.path,
      contentType: mimeTypeData != null
          ? MediaType(mimeTypeData[0], mimeTypeData[1])
          : MediaType('image', 'jpeg'),
    ));

    final response = await request.send();
    final respStr = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final decoded = json.decode(respStr);
      setState(() {
        _species = decoded['species'];
        _gender = decoded['gender'];
      });
    } else {
      setState(() {
        _species = 'Error';
        _gender = 'Error';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bird Identification')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _image != null
                ? Image.file(_image!, height: 200)
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .scale(duration: 500.ms)
                : Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(child: Text('No image selected')),
                  ).animate().fadeIn(),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Pick Image'),
            )
                .animate()
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.5, duration: 500.ms)
                .scale(),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator().animate().fadeIn().scale()
            else ...[
              if (_species != null)
                Text('Species: $_species',
                        style: const TextStyle(fontSize: 18))
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: -0.5),
              if (_gender != null)
                Text('Gender: $_gender',
                        style: const TextStyle(fontSize: 18))
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: 0.5),
            ]
          ],
        ),
      ),
    );
  }
}
