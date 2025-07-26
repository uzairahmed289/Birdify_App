import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const imgbbApiKey = '30b867aa9885cca834f786514b9a2dde';

Future<String?> uploadImageToImgbb(File imageFile) async {
  final url = Uri.parse("https://api.imgbb.com/1/upload?key=$imgbbApiKey");
  final base64Image = base64Encode(imageFile.readAsBytesSync());

  final response = await http.post(url, body: {
    'image': base64Image,
  });

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['data']['url'];
  } else {
    return null;
  }
}

class NewFeedListing extends StatefulWidget {
  @override
  _NewFeedListingState createState() => _NewFeedListingState();
}

class _NewFeedListingState extends State<NewFeedListing> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final weightController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  File? _pickedImage;
  bool _isSubmitting = false;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
    }
  }

  void submitListing() async {
  if (_isSubmitting) return;
  if (!_formKey.currentState!.validate()) return;

  if (_pickedImage == null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select an image')));
    return;
  }

  setState(() {
    _isSubmitting = true;
  });

  final imageUrl = await uploadImageToImgbb(_pickedImage!);
  if (imageUrl == null) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image upload failed')));
      setState(() => _isSubmitting = false);
    }
    return;
  }

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User not logged in')));
      setState(() => _isSubmitting = false);
    }
    return;
  }

  await FirebaseFirestore.instance
      .collection('listings')
      .doc('feed')
      .collection('listings')
      .add({
    'title': titleController.text.trim(),
    'weight': weightController.text.trim(),
    'price': int.tryParse(priceController.text.trim()) ?? 0,
    'description': descriptionController.text.trim(),
    'type': 'feed',
    'uid': user.uid,
    'imageUrl': imageUrl,
    'createdAt': Timestamp.now(),
  });

  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Feed listing added!')));
    Navigator.pop(context);
  }

  setState(() {
    _isSubmitting = false;
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Post a Feed Listing')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: _pickedImage != null
                      ? Image.file(_pickedImage!, fit: BoxFit.cover, width: double.infinity)
                      : Text('Tap to pick image', style: TextStyle(color: Colors.grey)),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Feed Title'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: weightController,
                decoration: InputDecoration(labelText: 'Weight (e.g. 2kg)'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
  controller: descriptionController,
  decoration: InputDecoration(labelText: 'Description'),
  maxLines: 3,
  validator: (value) => value!.isEmpty ? 'Required' : null,
),
              TextFormField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
  onPressed: _isSubmitting ? null : submitListing,
  child: _isSubmitting
      ? SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
      : Text('Submit'),
),

            ],
          ),
        ),
      ),
    );
  }
}
