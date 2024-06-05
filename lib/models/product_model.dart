import 'package:cloud_firestore/cloud_firestore.dart';
import 'brand_model.dart';
import 'product_attribute_model.dart';
import 'product_variation_model.dart';

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

  // Example toJSON and fromJSON methods for serialization
  Map<String, dynamic> toJson() {
    return {
      // 'Id': id,
      'Stock': stock,
      'SKU': sku,
      'Price': price,
      'Title': title,
      // 'Date': date?.toIso8601String(),
      'SalesPrice': salesPrice,
      'Thumbnail': thumbnail,
      'IsFeatured': isFeatured,
      'Brand': brand?.toJson(),
      'Description': description,
      'CategoryId': categoryId,
      'Images': images ?? [],
      'ProductType': productType,
      'ProductAttributes': productAttributes?.map((e) => e.toJson()).toList() ?? [],
      'ProductVariations': productVariations?.map((e) => e.toJson()).toList() ?? [],
    };
  }
  factory ProductModel.empty() {
    return ProductModel(
      id: '',
      stock: 0,
      sku: '',
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
  factory ProductModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
        if (data == null) {
      // Handle null data, return a default or empty product
      return ProductModel.empty();
    }
       return ProductModel(
      id: document.id,
      stock: data['Stock'],
      sku: data['SKU'],
      price: double.parse((data['Price'] ?? 0.0).toString()),
      title: data['Title'],
      // date: data['Date'] != null ? DateTime.parse(data['Date']) : null,
      salesPrice: double.parse((data['SalesPrice'] ?? 0.0).toString()),
      thumbnail: data['Thumbnail'],
      isFeatured: data['IsFeatured'] ?? false,
      brand: BrandModel.fromJson(data['Brand']) ,
      description: data['Description'],
      categoryId: data['CategoryId'],
      images: data['Images'] != null ? List<String>.from(data['Images']) : [],
      productType: data['ProductType'],
      productAttributes: (data['ProductAttributes'] as List<dynamic>).map((e)=> ProductAttributeModel.fromJson(e)).toList(),
      productVariations: (data['ProductAttributes'] as List<dynamic>).map((e)=> ProductVariationModel.fromJson(e)).toList(),
    );
  }

  factory ProductModel.fromQuerySnapshot(QueryDocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data() as Map<String, dynamic>;
    return ProductModel(
      id: document.id,
      stock: data['Stock'],
      sku: data['SKU'],
      price: double.parse((data['Price'] ?? 0.0).toString()),
      title: data['Title'],
      // date: data['Date'] != null ? DateTime.parse(data['Date']) : null,
      salesPrice: double.parse((data['SalesPrice'] ?? 0.0).toString()),
      thumbnail: data['Thumbnail'],
      isFeatured: data['IsFeatured'] ?? false,
      brand: data['Brand'] != null ? BrandModel.fromJson(data['Brand']) : null,
      description: data['Description'],
      categoryId: data['CategoryId'],
      images: data['Images'] != null ? List<String>.from(data['Images']) : [],
      productType: data['ProductType'],
      productAttributes: (data['ProductAttributes'] as List<dynamic>).map((e)=> ProductAttributeModel.fromJson(e)).toList(),
      productVariations: (data['ProductAttributes'] as List<dynamic>).map((e)=> ProductVariationModel.fromJson(e)).toList(),
    );
  }
}
