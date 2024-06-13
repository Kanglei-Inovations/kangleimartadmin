import 'dart:io';
import 'package:flutter/foundation.dart';
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
  bool _isLoading = false;
  int _currentUploadIndex = 0;
  double _uploadProgress = 0.0;

  String productType = 'ProductType.single';

  final List<ProductAttributeModel> attributes = [];
  final List<ProductVariationModel> variations = [];
  final TextEditingController attributeNameController = TextEditingController();
  final TextEditingController attributeValuesController =
      TextEditingController();
  List<String> _selectedImageUrls = [];
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
      variations.clear();
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
        print(_imagePaths);
      });
    }
  }

  void _submit() async {
    setState(() {
      _currentUploadIndex = 0;
      _uploadProgress = 0.0;
    });
    if (_formKey.currentState!.validate() && _imagePaths.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

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
      try {
        print(newProduct.toJson());
        await Provider.of<ProductProvider>(context, listen: false)
            .addProduct(newProduct, _imagePaths);
        Navigator.of(context).pop();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add product. Please try again.')),
        );
      } finally {
        setState(() {
          _isLoading = false;
          _currentUploadIndex = 0;
          _uploadProgress = 0.0;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please Enter all Required field')),
      );
    }
  }

  void deleteVariation(int index) {
    setState(() {
      variations.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
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
                    return Center(child: Container());
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
                    return Center(child: Container());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final brands = snapshot.data ?? [];
                    return DropdownButtonFormField<String>(
                      value: _brandCategory,
                      decoration: const InputDecoration(labelText: 'Brand'),
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
              const SizedBox(height: 20),
              const Text('All Product Images',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              SizedBox(
                height: 120,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _pickImages,
                      child: Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[300],
                        child: Icon(Icons.add_a_photo,
                            size: 40, color: Colors.grey),
                      ),
                    ),
                    Flexible(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _imagePaths.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: kIsWeb
                                ? Image.network(_imagePaths[index])
                                : Image.file(
                                    File(_imagePaths[index]),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.fill,
                                  ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Product Type',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile(
                      title: const Text('Single'),
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
                      title: const Text('Variant'),
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
                    TextField(
                      textCapitalization: TextCapitalization.words,
                      controller: attributeNameController,
                      decoration: const InputDecoration(
                          labelText: 'Attribute Name (e.g., Color, Size)'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            textCapitalization: TextCapitalization.words,
                            controller: attributeValuesController,
                            decoration: const InputDecoration(
                                labelText:
                                    'Attributes value (e.g. Green, Blue, Red)'),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        MaterialButton(
                          height: 20,
                          minWidth: 50,
                          color: Colors.green,
                          textColor: Colors.white,
                          padding: EdgeInsets.all(16.0),
                          splashColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          onPressed: addAttribute,
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: attributes.length,
                      itemBuilder: (context, index) {
                        final attribute = attributes[index];
                        return Card(
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text(
                                  '${attribute.name} (${attribute.values!.join(', ')})'),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () => removeAttribute(index),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 20),
                    MaterialButton(
                      height: 20,
                      color: attributes.isNotEmpty ? Colors.green : Colors.grey,
                      textColor: Colors.white,
                      padding: EdgeInsets.all(16.0),
                      splashColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      onPressed: generateVariations,
                      child: const Text('Generate variant'),
                    ),
                    const SizedBox(height: 20),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: variations.length,
                      itemBuilder: (context, index) {
                        final variation = variations[index];
                        return ExpansionTile(
                          title: Text(
                            'Product ${index + 1}: ${variation.attributeValues.entries.map((e) => '${e.key}: ${e.value}').join(', ')}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  TextField(
                                    controller: variation.skuController,
                                    decoration:
                                        InputDecoration(labelText: 'SKU'),
                                    onChanged: (value) => variation.sku = value,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: TextEditingController(
                                            text: _selectedImageUrls.isNotEmpty
                                                ? _selectedImageUrls.first
                                                : '',
                                          ),
                                          decoration: InputDecoration(
                                              labelText: 'Image URL'),
                                          readOnly: true,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          List<String> urls =
                                              await productProvider
                                                  .pickandUpload(
                                                      'product_images');
                                          if (urls.isNotEmpty) {
                                            setState(() {
                                              _selectedImageUrls.addAll(urls);
                                            });
                                          }
                                        },
                                        icon: Icon(Icons.add_a_photo),
                                      ),
                                    ],
                                  ),
                                  TextField(
                                    controller: variation.descriptionController,
                                    decoration: InputDecoration(
                                        labelText: 'Description'),
                                    onChanged: (value) =>
                                        variation.description = value,
                                  ),
                                  TextField(
                                    controller: variation.priceController,
                                    decoration:
                                        InputDecoration(labelText: 'Price'),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value){
                                      try {
                                        variation.price = double.parse(value);
                                      } catch (e) {
                                        variation.price = 0.0; // Or handle the error appropriately
                                        print('Invalid input for price: $value');
                                      }
                                    }

                                    // =>
                                    //     variation.price = double.parse(value),
                                  ),
                                  TextField(
                                    controller: variation.salePriceController,
                                    decoration: InputDecoration(
                                        labelText: 'Sale Price'),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      try {
                                        variation.salePrice =
                                            double.parse(value);
                                      } catch (e) {
                                        variation.salePrice =
                                            0.0; // Or handle the error appropriately
                                        print(
                                            'Invalid input for sale price: $value');
                                      }
                                    },
                                    // => variation.salePrice =
                                    //     double.parse(value),
                                  ),
                                  TextField(
                                    controller: variation.stockController,
                                    decoration:
                                        InputDecoration(labelText: 'Stock'),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      try {
                                        variation.stock = int.parse(value);
                                      } catch (e) {
                                        variation.stock = 0; // Or handle the error appropriately
                                        print('Invalid input for sale price: $value');
                                      }
                                    }

                                    // =>
                                    //     variation.stock = int.parse(value),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  MaterialButton(
                                      height: 10,
                                      minWidth: 10,
                                      color: Colors.red,
                                      textColor: Colors.white,
                                      padding: EdgeInsets.all(16.0),
                                      splashColor: Colors.grey,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      onPressed: () => deleteVariation(index),
                                      child: Icon(Icons.delete_outline_rounded)
                                      //Text('Delete Product ${index + 1}'),
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(10),
        child: _isLoading
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(
                    value: _uploadProgress / 100,
                    minHeight: 10,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Uploading product...',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('${_uploadProgress.toStringAsFixed(0)}% Complete'),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        setState(() {
                          _isLoading = false;
                          _imagePaths.clear();
                          _titleController.clear();
                          _descriptionController.clear();
                          _priceController.clear();
                          _salespriceController.clear();
                          _stockController.clear();
                          _skuController.clear();
                          _brandCategory = null;
                          _selectedCategory = null;
                          _isFeatured = false;
                          attributes.clear();
                          variations.clear();
                          attributeNameController.clear();
                          attributeValuesController.clear();
                        });
                      });
                    }, // Optional: Add cancel button functionality
                    child: Text('Cancel'),
                  ),
                ],
              )
            : MaterialButton(
                height: 20,
                color: Colors.green,
                textColor: Colors.white,
                padding: EdgeInsets.all(16.0),
                splashColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                onPressed: _submit,
                child: Text('Add Product'),
              ),
      ),
    );
  }
}
