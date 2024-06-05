import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/brand_provider.dart';
import '../models/brand_model.dart';

class AddBrandScreen extends StatefulWidget {
  static const routeName = '/add-brand';

  @override
  _AddBrandScreenState createState() => _AddBrandScreenState();
}

class _AddBrandScreenState extends State<AddBrandScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  File? _imageFile;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate() && _imageFile != null) {
      _formKey.currentState!.save();
      final newBrand = BrandModel(
        id: '', // This will be generated automatically by Firestore
        name: _nameController.text,
        image: '', // Temporary placeholder, will be replaced by the actual URL after upload
        isFeatured: false, // You can set this value as needed
        productsCount: 0, // Initially, no products are added
      );
      await Provider.of<BrandProvider>(context, listen: false).addBrand(newBrand, _imageFile!.path);
      Navigator.of(context).pop();
    } else {
      // Handle case where image is not selected
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select an image')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Brand'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              // Image picker
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text('Pick Image'),
                  ),
                  SizedBox(width: 10),
                  _imageFile != null
                      ? Image.file(
                    _imageFile!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  )
                      : Container(),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text('Add Brand'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
