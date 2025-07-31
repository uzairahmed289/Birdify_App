import 'dart:convert';
import 'dart:io';
import 'package:birdify_flutter/constants/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IdentificationPage extends StatefulWidget {
  const IdentificationPage({super.key});

  @override
  State<IdentificationPage> createState() => _IdentificationPageState();
}

class _IdentificationPageState extends State<IdentificationPage> {
  File? _image;
  bool _isLoading = false;
  String? _species;
  String? _gender;
  String? _error;

  final ImagePicker _picker = ImagePicker();

  // Inside your State class
final List<String> _supportedBirds = [
    'American Redstart',
    'Koel',
    'Brewer Bird',
    'Cardinal',
    'Eclectus',
    'Indian Paradise',
    'Indigo Bunting',
    'Lesser Paradise',
    'Northern Pin Tail',
    'Orchard Oriol',
    'Ostrich',
    'Peacock',
    'Purple Finch',
    'Purple Martin',
    'Southern Kohran',
    'Spectacled Eider',
    'Turkey Bird',
    'Western Capercaillie',
    'Western Parotia',
    'Wood Duck',
];

void _showSupportedBirdsDialog() {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.bird, color: Colors.teal),
                SizedBox(width: 8),
                Text(
                  "Supported Birds",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _supportedBirds.length,
                separatorBuilder: (_, __) => const Divider(height: 10),
                itemBuilder: (context, index) => ListTile(
                  leading: const Icon(Icons.check_circle_outline, color: Colors.teal),
                  title: Text(_supportedBirds[index]),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
              label: const Text("Close"),
              style: TextButton.styleFrom(
                foregroundColor: Colors.teal,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  void _showImageSourceSelector() {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (BuildContext context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _pickImage(ImageSource source) async {
  final pickedFile = await _picker.pickImage(source: source);
  if (pickedFile != null) {
    setState(() {
      _image = File(pickedFile.path);
      _species = null;
      _gender = null;
      _error = null;
    });
    await _identifyBird();
  }
}

Future<String?> _getNgrokUrl() async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('config')
        .doc('ngrok_url')
        .get();

    if (doc.exists) {
      return doc['url']; // Assuming your Firestore doc has a field "url"
    }
  } catch (e) {
    print('Error fetching ngrok URL: $e');
  }
  return null;
}


Future<void> _identifyBird() async {
  if (_image == null) return;

  setState(() {
    _isLoading = true;
  });

  try {
    final ngrokUrl = await _getNgrokUrl();
    if (ngrokUrl == null) {
      setState(() {
        _error = 'Could not fetch API URL from Firestore.';
        _isLoading = false;
      });
      return;
    }

    final uri = Uri.parse('$ngrokUrl/predict/');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', _image!.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      setState(() {
        _species = responseData['species'];
        _gender = responseData['gender'];
        _error = null;
      });
    } else {
      setState(() {
        _error = 'Failed to get prediction. Server error.';
      });
    }
  } catch (e) {
    setState(() {
      _error = 'Error: $e';
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
  title: const Text("AI Powered Bird Identifier"),
  centerTitle: true,
  backgroundColor: AppColors.darkBlue,
  foregroundColor: Colors.white,
  actions: [
    IconButton(
      icon: const Icon(Icons.info_outline),
      onPressed: _showSupportedBirdsDialog,
    ),
  ],
),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🔹 AI-Powered Banner
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt, color: Colors.deepPurple),
                      SizedBox(width: 8),
                      Text(
                        "AI-Powered Bird Identifier",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: -0.3, duration: 600.ms),
              ),
              const SizedBox(height: 16),

              // 🔹 Subtitle
              const Text(
                "Instantly identify bird species and gender using AI.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ).animate().fadeIn().slideY(begin: 0.5),
              const SizedBox(height: 24),

              // 🔹 Pick Image Button
              ElevatedButton.icon(
                onPressed: _showImageSourceSelector,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.image, color: Colors.white),
                label: const Text(
                  "Pick Image from Gallery",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ).animate().fadeIn().slideY(begin: 0.4),
              const SizedBox(height: 24),

              // 🔹 Show Selected Image
              if (_image != null)
  ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: SizedBox(
      height: 200, // or MediaQuery.of(context).size.height * 0.3
      width: double.infinity,
      child: Image.file(
        _image!,
        fit: BoxFit.fitHeight,
      ),
    ),
  ).animate().fadeIn().scale(),


              const SizedBox(height: 24),

              // 🔹 Loading Indicator
              if (_isLoading)
                Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    const Text("Analyzing image with AI..."),
                  ],
                ).animate().fadeIn(),

              // 🔹 Show Result
              if (!_isLoading && (_species != null || _gender != null))
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_species != null)
                          Text("Species: $_species",
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        if (_gender != null)
                          Text("Gender: $_gender",
                              style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ).animate().fadeIn().scale(),

              // 🔹 Show Error
              if (_error != null)
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ).animate().fadeIn(),
            ],
          ),
        ),
      ),
    );
  }
}
