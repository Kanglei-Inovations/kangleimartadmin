import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/brand_model.dart';
import '../models/category_model.dart';
import '../models/product_attribute_model.dart';
import '../models/product_variation_model.dart';
import '../providers/brand_provider.dart';
import '../providers/category_provider.dart';
import '../providers/product_provider.dart';
import '../models/product_model.dart';

class AddProductScreen extends StatefulWidget {
  static const routeName = '/add-product';

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _skuController = TextEditingController();
  final _titleController = TextEditingController();
  String? _selectedCategory;
  String? _brandCategory;
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _salespriceController = TextEditingController();
  final _stockController = TextEditingController();
  List<String> _imagePaths = [];
  final ImagePicker _picker = ImagePicker();
  bool _isFeatured = false;
// Define controllers for attribute inputs
  final _attributeNameController = TextEditingController();
  final _attributeValuesController = TextEditingController();
  final _variationSKUController = TextEditingController();
  final _variationPriceController = TextEditingController();
  final _variationSalePriceController = TextEditingController();
  final _variationStockController = TextEditingController();
  final _variationAttributeValuesController = TextEditingController();
  List<ProductAttributeModel> _productAttributes = [];
  List<ProductVariationModel> _productVariations = [];

  void _addAttribute() {
    final attributeName = _attributeNameController.text.trim();
    final attributeValues = _attributeValuesController.text
        .split(',')
        .map((e) => e.trim())
        .toList();

    if (attributeName.isNotEmpty && attributeValues.isNotEmpty) {
      setState(() {
        _productAttributes.add(
          ProductAttributeModel(name: attributeName, values: attributeValues),
        );
        _attributeNameController.clear();
        _attributeValuesController.clear();
      });
    }
  }


  void _addVariation() {
    final sku = _variationSKUController.text;
    final price = double.tryParse(_variationPriceController.text) ?? 0.0;
    final salePrice = double.tryParse(_variationSalePriceController.text) ?? 0.0;
    final stock = int.tryParse(_variationStockController.text) ?? 0;
    final attributeValues = Map<String, String>.fromIterable(
      _variationAttributeValuesController.text.split(','),
      key: (item) => item.split(':')[0].trim(),
      value: (item) => item.split(':')[1].trim(),
    );
    if (sku.isNotEmpty) {
      setState(() {
        _productVariations.add(ProductVariationModel(
          id: '', // Temporary ID or generate a unique ID
          sku: sku,
          price: price,
          salePrice: salePrice,
          stock: stock,
          attributeValues: attributeValues,
        ));
      });
      _variationSKUController.clear();
      _variationPriceController.clear();
      _variationSalePriceController.clear();
      _variationStockController.clear();
      _variationAttributeValuesController.clear();
    }
  }



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
        id: '',
        sku: _skuController.text,
        title: _titleController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        thumbnail: '',
        stock: int.parse(_stockController.text),
        salesPrice: double.parse(_salespriceController.text),
        isFeatured: _isFeatured,
        brandId: _brandCategory,
        categoryId: _selectedCategory,
        images: [],
        productType: '',
        productAttributes: _productAttributes,
        productVariations: _productVariations,
      );
      await Provider.of<ProductProvider>(context, listen: false).addProduct(newProduct, _imagePaths);
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select at least one image')));
    }
  }

  @override
  void dispose() {
    _skuController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _salespriceController.dispose();
    _stockController.dispose();
    _attributeNameController.dispose();
    _attributeValuesController.dispose();
    _variationSKUController.dispose();
    _variationPriceController.dispose();
    _variationSalePriceController.dispose();
    _variationStockController.dispose();
    _variationAttributeValuesController.dispose();
    super.dispose();
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
                controller: _skuController,
                decoration: InputDecoration(labelText: 'SKU Code'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a SKU Code';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Product Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a Product title';
                  }
                  return null;
                },
              ),
              StreamBuilder<List<CategoryModel>>(
                stream: Provider.of<CategoryProvider>(context).streamCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final categories = snapshot.data ?? [];
                    return DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(labelText: 'Category'),
                      items: categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Select Category';
                        }
                        return null;
                      },
                    );
                  }
                },
              ),
              StreamBuilder<List<BrandModel>>(
                stream: Provider.of<BrandProvider>(context).streamBrands(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final brands = snapshot.data ?? [];
                    return DropdownButtonFormField<String>(
                      value: _brandCategory,
                      decoration: InputDecoration(labelText: 'Brand'),
                      items: brands.map((brand) {
                        return DropdownMenuItem<String>(
                          value: brand.id,
                          child: Text(brand.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _brandCategory = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Select Brand';
                        }
                        return null;
                      },
                    );
                  }
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
                decoration: InputDecoration(labelText: 'MRP Price'),
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
              TextFormField(
                controller: _salespriceController,
                decoration: InputDecoration(labelText: 'Sales/Offer Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a sale price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
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
              ElevatedButton(
                onPressed: _pickImages,
                child: Text('Pick Images'),
              ),
              Container(
                height: 120,
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
              SwitchListTile(
                title: Text('Featured'),
                value: _isFeatured,
                onChanged: (bool value) {
                  setState(() {
                    _isFeatured = value;
                  });
                },
              ),

              Text('Product Attributes'),
              TextFormField(
                controller: _attributeNameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextFormField(
                controller: _attributeValuesController,
                decoration: InputDecoration(labelText: 'Values'),
              ),
              ElevatedButton(
                onPressed: _addAttribute,
                child: Text('Add Attribute'),
              ),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _productAttributes.map((attribute) {
                  return Chip(
                    label: Text('${attribute.name}: ${attribute.values!.join(', ')}'),
                  );
                }).toList(),
              ),

              Text('Product Variations'),
              TextFormField(
                controller: _variationSKUController,
                decoration: InputDecoration(labelText: 'SKU'),
              ),
              TextFormField(
                controller: _variationPriceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _variationSalePriceController,
                decoration: InputDecoration(labelText: 'Sale Price'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _variationStockController,
                decoration: InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _variationAttributeValuesController,
                decoration: InputDecoration(labelText: 'Attribute Values (key:value pairs, comma separated)'),
              ),
              ElevatedButton(
                onPressed: _addVariation,
                child: Text('Add Variation'),
              ),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _productVariations.map((variation) {
                  return Chip(
                    label: Text(
                        'SKU: ${variation.sku}, Price: ${variation.price}, Sale Price: ${variation.salePrice}, Stock: ${variation.stock}, Attributes: ${variation.attributeValues.entries.map((e) => '${e.key}:${e.value}').join(', ')}'),
                  );
                }).toList(),
              ),


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
