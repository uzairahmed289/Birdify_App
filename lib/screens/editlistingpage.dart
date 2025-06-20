import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditListingPage extends StatefulWidget {
  final DocumentSnapshot listing;

  EditListingPage({required this.listing});

  @override
  _EditListingPageState createState() => _EditListingPageState();
}

class _EditListingPageState extends State<EditListingPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    final data = widget.listing.data() as Map<String, dynamic>;
    _titleController = TextEditingController(text: data['name'] ?? data['title']);
    _priceController = TextEditingController(text: data['price']);
    _descriptionController = TextEditingController(text: data['description'] ?? '');
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      await widget.listing.reference.update({
        'title': _titleController.text.trim(),
        'price': _priceController.text.trim(),
        'description': _descriptionController.text.trim(),
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Listing updated')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Listing')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _saveChanges, child: Text('Save Changes')),
            ],
          ),
        ),
      ),
    );
  }
}
