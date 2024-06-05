import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product_model.dart';

class AddProductScreen extends StatefulWidget {
  static const routeName = '/add-product';

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  final _stockController = TextEditingController();
  final _ratingController = TextEditingController();
  List<String> _imagePaths = []; // Updated to store multiple image paths

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _imagePaths = pickedFiles.map((file) => file.path).toList();
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate() && _imagePaths.isNotEmpty) {
      _formKey.currentState!.save();
      final newProduct = ProductModel(
        id: '', // This will be generated automatically by Firestore
        title: _titleController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        thumbnail: '', // Temporary placeholder, will be replaced by the actual URL after upload
        stock: int.parse(_stockController.text),
        salesPrice: 0, // You can set this value as needed
        isFeatured: false, // You can set this value as needed
        brand: null, // You can set this value as needed
        categoryId: _categoryController.text,
        images: [], // Updated to include multiple images
        productType: '', // You can set this value as needed
        productAttributes: [], // Initially, no attributes are added
        productVariations: [], // Initially, no variations are added
      );
      await Provider.of<ProductProvider>(context, listen: false).addProduct(newProduct,_imagePaths);
      Navigator.of(context).pop();
    } else {
      // Handle case where images are not selected
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select at least one image')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              // Image picker
              ElevatedButton(
                onPressed: _pickImages,
                child: Text('Pick Images'),
              ),
              Container(
                height: 120, // Specify a fixed height for the container
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imagePaths.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.file(
                        File(_imagePaths[index]),
                        width: 100,
                        height: 100,
                        fit: BoxFit.fill,
                      ),
                    );
                  },
                ),
              ),

              SizedBox(width: 10),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: 'Category'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _stockController,
                decoration: InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the stock quantity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _ratingController,
                decoration: InputDecoration(labelText: 'Rating'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a rating';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text('Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
