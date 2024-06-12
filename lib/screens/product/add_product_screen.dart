import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/brand_model.dart';
import '../../models/category_model.dart';
import '../../models/product_attribute_model.dart';
import '../../models/product_model.dart';
import '../../models/product_variation_model.dart';
import '../../providers/brand_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/product_provider.dart';

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
  String productType = 'ProductType.single';

  final List<ProductAttributeModel> attributes = [];
  final List<ProductVariationModel> variations = [];
  final TextEditingController attributeNameController = TextEditingController();
  final TextEditingController attributeValuesController =
      TextEditingController();

  @override
  void dispose() {
    attributeNameController.dispose();
    attributeValuesController.dispose();
    _skuController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _salespriceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void addAttribute() {
    final name = attributeNameController.text.trim();
    final values =
        attributeValuesController.text.split(',').map((e) => e.trim()).toList();

    if (name.isNotEmpty && values.isNotEmpty) {
      setState(() {
        attributes.add(ProductAttributeModel(name: name, values: values));
      });
      attributeNameController.clear();
      attributeValuesController.clear();
    }
  }

  void removeAttribute(int index) {
    setState(() {
      attributes.removeAt(index);
    });
  }

  void generateVariations() {
    final List<ProductVariationModel> newVariations = [];
    final Map<String, List<String>> attributeMap = {
      for (var attr in attributes) attr.name!: attr.values!
    };
    final combinations = generateCombinations(attributeMap);
    int idCounter = 0;

    for (var combination in combinations) {
      final id = idCounter.toString(); // Sequential IDs starting from 0
      idCounter++;
      newVariations
          .add(ProductVariationModel(id: id, attributeValues: combination));
    }

    setState(() {
      variations.clear();
      variations.addAll(newVariations);
    });
  }

  List<Map<String, String>> generateCombinations(
      Map<String, List<String>> attributeMap) {
    if (attributeMap.isEmpty) return [];

    final keys = attributeMap.keys.toList();
    final List<Map<String, String>> results = [];

    void combine(int depth, Map<String, String> current) {
      if (depth == keys.length) {
        results.add(Map<String, String>.from(current));
        return;
      }

      final key = keys[depth];
      for (var value in attributeMap[key]!) {
        current[key] = value;
        combine(depth + 1, current);
      }
    }

    combine(0, {});
    return results;
  }

  String generateIdFromCombination(Map<String, String> combination) {
    String id = '';
    for (var attribute in attributes) {
      final attributeName = attribute.name!;
      final attributeValue = combination[attributeName];
      final index = attribute.values!.indexOf(attributeValue!);
      id += index.toString();
    }
    return id;
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

      double? price;
      double? salesPrice;
      int? stock;

      if (productType == 'ProductType.single') {
        price = double.parse(_priceController.text);
        salesPrice = double.parse(_salespriceController.text);
        stock = int.parse(_stockController.text);
      } else if (productType == 'ProductType.variable') {
        price = null; // No overall price for variable products
        salesPrice = null; // No overall sales price for variable products
        stock = null;
      }

      final newProduct = ProductModel(
        id: '',
        sku: productType == 'ProductType.single' ? _skuController.text : '',
        title: _titleController.text,
        description: _descriptionController.text,
        price: price ?? 0.0,
        thumbnail: '',
        stock: stock ?? 0,
        salesPrice: salesPrice ?? 0.0,
        isFeatured: _isFeatured,
        brandId: _brandCategory,
        categoryId: _selectedCategory,
        images: [],
        productType: productType,
        productAttributes: attributes,
        productVariations: variations,
      );

      print(newProduct.toJson());
      await Provider.of<ProductProvider>(context, listen: false)
          .addProduct(newProduct, _imagePaths);
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please Enter all Required field')),
      );
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
              SwitchListTile(
                title: Text(
                  'Visible',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                value: _isFeatured,
                onChanged: (bool value) {
                  setState(() {
                    _isFeatured = value;
                  });
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
              StreamBuilder<List<CategoryModel>>(
                stream:
                    Provider.of<CategoryProvider>(context).streamCategories(),
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

              SizedBox(height: 20),
              Text('All Product Images',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Container(
                height: 120,
                child: Row(children: [
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: 50,
                      height: 100,
                      color: Colors.grey[300],
                      child:
                          Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                    ),
                  ),
                  Flexible(
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
                ]),
              ),
              SizedBox(height: 5),
              Text(
                'Product Type',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile(
                      title: Text('Single'),
                      value: 'ProductType.single',
                      groupValue: productType,
                      onChanged: (value) {
                        setState(() {
                          productType = value.toString();
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile(
                      title: Text('Variable'),
                      value: 'ProductType.variable',
                      groupValue: productType,
                      onChanged: (value) {
                        setState(() {
                          productType = value.toString();
                        });
                      },
                    ),
                  ),
                ],
              ),

              if (productType == 'ProductType.single')
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
              if (productType == 'ProductType.single')
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
              if (productType == 'ProductType.single')
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
              if (productType == 'ProductType.single')
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

              Visibility(
                visible: productType == 'ProductType.variable',
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: attributeNameController,
                            decoration: InputDecoration(
                                labelText: 'Attribute Name (e.g., Color)'),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: attributeValuesController,
                            decoration: InputDecoration(
                                labelText:
                                    'Attributes (e.g., Green, Blue, Red)'),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: addAttribute,
                        ),
                      ],
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: attributes.length,
                      itemBuilder: (context, index) {
                        final attribute = attributes[index];
                        return ListTile(
                          title: Text(
                              '${attribute.name} (${attribute.values!.join(', ')})'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => removeAttribute(index),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: generateVariations,
                      child: Text('Generate Variations'),
                    ),
                    SizedBox(height: 20),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: variations.length,
                      itemBuilder: (context, index) {
                        final variation = variations[index];
                        return ExpansionTile(
                          title: Text(
                            'Product ${index + 1}: ${variation.attributeValues.entries.map((e) => '${e.key}: ${e.value}').join(', ')}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  TextField(
                                    decoration:
                                        InputDecoration(labelText: 'SKU'),
                                    onChanged: (value) => variation.sku = value,
                                  ),
                                  TextField(
                                    decoration:
                                        InputDecoration(labelText: 'Image URL'),
                                    onChanged: (value) =>
                                        variation.image = value,
                                  ),
                                  TextField(
                                    decoration: InputDecoration(
                                        labelText: 'Description'),
                                    onChanged: (value) =>
                                        variation.description = value,
                                  ),
                                  TextField(
                                    decoration:
                                        InputDecoration(labelText: 'Price'),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) =>
                                        variation.price = double.parse(value),
                                  ),
                                  TextField(
                                    decoration: InputDecoration(
                                        labelText: 'Sale Price'),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) => variation.salePrice =
                                        double.parse(value),
                                  ),
                                  TextField(
                                    decoration:
                                        InputDecoration(labelText: 'Stock'),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) =>
                                        variation.stock = int.parse(value),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              // TextFormField(
              //   controller: _skuController,
              //   decoration: InputDecoration(labelText: 'SKU Code'),
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Please enter a SKU Code';
              //     }
              //     return null;
              //   },
              // ),
              // TextFormField(
              //   controller: _priceController,
              //   decoration: InputDecoration(labelText: 'MRP Price'),
              //   keyboardType: TextInputType.number,
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Please enter a price';
              //     }
              //     if (double.tryParse(value) == null) {
              //       return 'Please enter a valid number';
              //     }
              //     return null;
              //   },
              // ),
              // TextFormField(
              //   controller: _salespriceController,
              //   decoration: InputDecoration(labelText: 'Sales/Offer Price'),
              //   keyboardType: TextInputType.number,
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Please enter a sale price';
              //     }
              //     if (double.tryParse(value) == null) {
              //       return 'Please enter a valid number';
              //     }
              //     return null;
              //   },
              // ),
              // TextFormField(
              //   controller: _stockController,
              //   decoration: InputDecoration(labelText: 'Stock'),
              //   keyboardType: TextInputType.number,
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Please enter the stock quantity';
              //     }
              //     if (int.tryParse(value) == null) {
              //       return 'Please enter a valid number';
              //     }
              //     return null;
              //   },
              // ),
              //
              // Row(
              //   children: [
              //     Expanded(
              //       child: TextField(
              //         controller: attributeNameController,
              //         decoration: InputDecoration(labelText: 'Attribute Name (e.g., Color)'),
              //       ),
              //     ),
              //     SizedBox(width: 10),
              //     Expanded(
              //       child: TextField(
              //         controller: attributeValuesController,
              //         decoration: InputDecoration(labelText: 'Attributes (e.g., Green, Blue, Red)'),
              //       ),
              //     ),
              //     IconButton(
              //       icon: Icon(Icons.add),
              //       onPressed: addAttribute,
              //     ),
              //   ],
              // ),
              // ListView.builder(
              //   shrinkWrap: true,
              //   itemCount: attributes.length,
              //   itemBuilder: (context, index) {
              //     final attribute = attributes[index];
              //     return ListTile(
              //       title: Text('${attribute.name} (${attribute.values!.join(', ')})'),
              //       trailing: IconButton(
              //         icon: Icon(Icons.delete),
              //         onPressed: () => removeAttribute(index),
              //       ),
              //     );
              //   },
              // ),
              // SizedBox(height: 20),
              // ElevatedButton(
              //   onPressed: generateVariations,
              //   child: Text('Generate Variations'),
              // ),
              // SizedBox(height: 20),
              // ListView.builder(
              //   shrinkWrap: true,
              //   itemCount: variations.length,
              //   itemBuilder: (context, index) {
              //     final variation = variations[index];
              //     return ExpansionTile(
              //       title: Text('Variation ${index + 1}: ${variation.attributeValues.entries.map((e) => '${e.key}: ${e.value}').join(', ')}'),
              //       children: [
              //         Padding(
              //           padding: const EdgeInsets.all(8.0),
              //           child: Column(
              //             children: [
              //               TextField(
              //                 decoration: InputDecoration(labelText: 'SKU'),
              //                 onChanged: (value) => variation.sku = value,
              //               ),
              //               TextField(
              //                 decoration: InputDecoration(labelText: 'Image URL'),
              //                 onChanged: (value) => variation.image = value,
              //               ),
              //               TextField(
              //                 decoration: InputDecoration(labelText: 'Description'),
              //                 onChanged: (value) => variation.description = value,
              //               ),
              //               TextField(
              //                 decoration: InputDecoration(labelText: 'Price'),
              //                 keyboardType: TextInputType.number,
              //                 onChanged: (value) => variation.price = double.parse(value),
              //               ),
              //               TextField(
              //                 decoration: InputDecoration(labelText: 'Sale Price'),
              //                 keyboardType: TextInputType.number,
              //                 onChanged: (value) => variation.salePrice = double.parse(value),
              //               ),
              //               TextField(
              //                 decoration: InputDecoration(labelText: 'Stock'),
              //                 keyboardType: TextInputType.number,
              //                 onChanged: (value) => variation.stock = int.parse(value),
              //               ),
              //             ],
              //           ),
              //         ),
              //       ],
              //     );
              //   },
              // ),

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
