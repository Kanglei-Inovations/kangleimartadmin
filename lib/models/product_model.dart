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
  DateTime? date;
  double salesPrice;
  String thumbnail;
  bool? isFeatured;
  BrandModel? brand;
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
    this.date,
    required this.salesPrice,
    required this.thumbnail,
    this.isFeatured,
    this.brand,
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
      date: null,
      salesPrice: 0.0,
      thumbnail: '',
      isFeatured: false,
      brand: null,
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
      'Date': date?.toIso8601String(),
      'SalesPrice': salesPrice,
      'Thumbnail': thumbnail,
      'IsFeatured': isFeatured,
      'Brand': brand?.toJson(),
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
      date: (data['Date'] as Timestamp?)?.toDate(),
      salesPrice: (data['SalesPrice'] ?? 0.0).toDouble(),
      thumbnail: data['Thumbnail'] ?? '',
      isFeatured: data['IsFeatured'] ?? false,
      brand: data['Brand'] != null ? BrandModel.fromJson(data['Brand']) : null,
      description: data['Description'] ?? '',
      categoryId: data['CategoryId'] ?? '',
      images: (data['Images'] as List<dynamic>?)?.cast<String>(),
      productType: data['ProductType'] ?? '',
      productAttributes: (data['ProductAttributes'] as List<dynamic>?)?.map<ProductAttributeModel>((e) => ProductAttributeModel.fromJson(e)).toList(),
      productVariations: (data['ProductVariations'] as List<dynamic>?)?.map<ProductVariationModel>((e) => ProductVariationModel.fromJson(e)).toList(),
    );
  }
}
