import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/brand_model.dart';
import 'product_attribute_model.dart';
import 'product_variation_model.dart'; // Assuming you have a BrandModel class defined

class ProductModel {
  String id;
  int stock;
  String? sku;
  double price;
  String title;

  double salesPrice;
  String thumbnail;
  bool isFeatured;
  String? brandId;
  String? description;
  String? categoryId;
  List<String>? images;
  String productType;
  List<ProductAttributeModel>? productAttributes;
  List<ProductVariationModel>? productVariations;

  ProductModel({
    required this.id,
    required this.stock,
    this.sku,
    required this.price,
    required this.title,

    required this.salesPrice,
    required this.thumbnail,
    this.isFeatured = true,
    this.brandId,
    this.description,
    this.categoryId,
    this.images,
    required this.productType,
    this.productAttributes,
    this.productVariations,
  });

  factory ProductModel.empty() {
    return ProductModel(
      id: '',
      stock: 0,
      sku: null,
      price: 0.0,
      title: '',

      salesPrice: 0.0,
      thumbnail: '',
      isFeatured: false,
      brandId: '',
      description: '',
      categoryId: '',
      images: [],
      productType: '',
      productAttributes: [],
      productVariations: [],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Stock': stock,
      'SKU': sku,
      'Price': price,
      'Title': title,

      'SalesPrice': salesPrice,
      'Thumbnail': thumbnail,
      'IsFeatured': isFeatured,
      'BrandId': brandId,
      'Description': description,
      'CategoryId': categoryId,
      'Images': images,
      'ProductType': productType,
      'ProductAttributes': productAttributes?.map((e) => e.toJson()).toList(),
      'ProductVariations': productVariations?.map((e) => e.toJson()).toList(),
    };
  }
  factory ProductModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return ProductModel(
      id: document.id,
      stock: data['Stock'] ?? 0,
      sku: data['SKU'],
      price: (data['Price'] ?? 0.0).toDouble(),
      title: data['Title'] ?? '',

      salesPrice: (data['SalesPrice'] ?? 0.0).toDouble(),
      thumbnail: data['Thumbnail'] ?? '',
      isFeatured: data['IsFeatured'] ?? false,
      brandId:  data['BrandId'] ?? '',
      description: data['Description'] ?? '',
      categoryId: data['CategoryId'] ?? '',
      images: (data['Images'] as List<dynamic>?)?.cast<String>(),
      productType: data['ProductType'] ?? '',
      productAttributes: (data['ProductAttributes'] as List<dynamic>?)?.map<ProductAttributeModel>((e) => ProductAttributeModel.fromJson(e)).toList(),
      productVariations: (data['ProductVariations'] as List<dynamic>?)?.map<ProductVariationModel>((e) => ProductVariationModel.fromJson(e)).toList(),
    );
  }
}
