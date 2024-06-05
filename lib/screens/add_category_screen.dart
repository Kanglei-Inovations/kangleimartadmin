import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import '../providers/category_provider.dart';

class AddCategoryScreen extends StatefulWidget {
  static const routeName = '/add-category';

  @override
  _AddCategoryScreenState createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isFeatured = false;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  void _submit() async {
    if (_formKey.currentState!.validate() && _imageFile != null) {
      final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
      String imageUrl = await categoryProvider.uploadImage(_imageFile!.path);
      final newCategory = CategoryModel(
        id: '',
        name: _nameController.text,
        image: imageUrl,
        isFeatured: _isFeatured,
      );
      await categoryProvider.addCategory(newCategory);
      Navigator.of(context).pop();
    } else if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select an image')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Category'),
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
              SizedBox(height: 20),
              Row(
                children: [
                  _imageFile != null
                      ? Image.file(_imageFile!, width: 100, height: 100, fit: BoxFit.cover)
                      : Text('No image selected.'),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text('Select Image'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              SwitchListTile(
                title: Text('Featured'),
                value: _isFeatured,
                onChanged: (bool value) {
                  setState(() {
                    _isFeatured = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text('Add Category'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
