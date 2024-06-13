import 'package:flutter/material.dart';

class ProductVariationModel {
  final String id;
  String sku;
  String image;
  String? description;
  double price;
  double salePrice;
  int stock;
  Map<String, String> attributeValues;
  TextEditingController skuController;
  TextEditingController imageController;
  TextEditingController descriptionController;
  TextEditingController priceController;
  TextEditingController salePriceController;
  TextEditingController stockController;

  ProductVariationModel({
    required this.id,
    this.sku = '',
    this.image = '',
    this.description,
    this.price = 0.0,
    this.salePrice = 0.0,
    this.stock = 0,
    required this.attributeValues,
  }):  skuController = TextEditingController(text: sku),
        imageController = TextEditingController(text: image),
        descriptionController = TextEditingController(text: description),
        priceController = TextEditingController(text: price.toString()),
        salePriceController = TextEditingController(text: salePrice.toString()),
        stockController = TextEditingController(text: stock.toString());

  // Add a method to dispose the controllers
  void dispose() {
    skuController.dispose();
    imageController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    salePriceController.dispose();
    stockController.dispose();
  }


  // Create an empty function for clean code
  static ProductVariationModel empty() => ProductVariationModel(id: '', attributeValues: {});

  // Example toJSON and fromJSON methods for serialization
  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'SKU': sku,
      'Image': image,
      'Description': description,
      'Price': price,
      'SalePrice': salePrice,
      'Stock': stock,
      'AttributeValues': attributeValues,
    };
  }

//map json document snapshot from firebase to userModel
  factory ProductVariationModel.fromJson(Map<String, dynamic> document) {
    final data = document;
    if (data.isEmpty) return ProductVariationModel.empty();
    return ProductVariationModel(
      id: data['Id'],
      sku: data['SKU'],
      image: data['Image'],
      description: data['Description'],
      price: double.parse((data['Price'] ?? 0.0).toString()),
      salePrice: double.parse((data['SalePrice'] ?? 0.0).toString()),
      stock: data['Stock'],
      attributeValues: Map<String, String>.from(data['AttributeValues']),
    );
  }
}
