import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  String id;
  String name;
  String image;
  bool? isFeatured;

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    this.isFeatured,
  });

  // Factory constructor to create an empty CategoryModel
  factory CategoryModel.empty() {
    return CategoryModel(
      id: '',
      name: '',
      image: '',
      isFeatured: false,
    );
  }

  // Method to convert a CategoryModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Name': name,
      'Image': image,
      'IsFeatured': isFeatured,
    };
  }

  // Factory constructor to create a CategoryModel from a JSON map
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['Id'] ?? '',
      name: json['Name'] ?? '',
      image: json['Image'] ?? '',
      isFeatured: json['IsFeatured'] ?? false,
    );
  }

  // Factory constructor to create a CategoryModel from a Firestore document snapshot
  factory CategoryModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data != null) {
      return CategoryModel(
        id: snapshot.id,
        name: data['Name'] ?? '',
        image: data['Image'] ?? '',
        isFeatured: data['IsFeatured'] ?? false,
      );
    }
    return CategoryModel.empty();
  }
}
