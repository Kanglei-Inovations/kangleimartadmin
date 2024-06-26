import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import '../models/category_model.dart';
import '../models/product_model.dart';

class ProductProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  List<ProductModel> _products = [];
  Map<String, String> _categoryNames = {}; // Cache category names
  Map<String, String> _brandNames = {}; // Cache brand names
  List<ProductModel> get products {
    return [..._products];
  }
  final ImagePicker _picker = ImagePicker();

  Stream<List<ProductModel>> streamProducts() {
    return _db.collection('products').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => ProductModel.fromSnapshot(doc)).toList());
  }

  Future<List<String>> pickandUpload(String location) async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      List<String> downloadUrls = [];
      for (var file in pickedFiles) {
        String fileName = path.basename(file.path);
        File imageFile = File(file.path);
        try {
          TaskSnapshot snapshot = await _storage.ref('$location/$fileName').putFile(imageFile);
          String downloadUrl = await snapshot.ref.getDownloadURL();
          downloadUrls.add(downloadUrl);
        } catch (e) {
          print('Error uploading image: $e');
        }
      }
      return downloadUrls;
    }
    return [];
  }

  Future<void> addProduct(ProductModel product, List<String> imagePaths) async {
    try {
      // Upload the images to Firebase Storage
      List<String> imageUrls = await _uploadImages(imagePaths);

      // Add the product to Firestore with the image URLs
      await _db.collection('products').add({
        ...product.toJson(),
        'Images': imageUrls,
        'CreatedAt': FieldValue.serverTimestamp(), // Set the server timestamp
      });
      // Update the local list of products
      notifyListeners();
    } catch (e) {
      print('Error adding product: $e');
      throw e;
    }
  }

  Future<List<String>> _uploadImages(List<String> imagePaths) async {
    List<String> imageUrls = [];
    for (String imagePath in imagePaths) {
      File file = File(imagePath);
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = _storage.ref().child('product_images').child(fileName);
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask.whenComplete(() => {});
      String downloadUrl = await snapshot.ref.getDownloadURL();
      imageUrls.add(downloadUrl);
    }
    return imageUrls;
  }

  Future<void> updateIsFeatured(String id, bool isFeatured) async {
    try {
      await _db.collection('products').doc(id).update({'IsFeatured': isFeatured});
      notifyListeners();
    } catch (e) {
      print('Error updating isFeatured: $e');
      throw e;
    }
  }

  Future<String> getCategoryName(String categoryId) async {
    if (_categoryNames.containsKey(categoryId)) {
      return _categoryNames[categoryId]!;
    } else {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await _db.collection('categories').doc(categoryId).get();
      if (snapshot.exists) {
        CategoryModel category = CategoryModel.fromSnapshot(snapshot);
        _categoryNames[categoryId] = category.name;
        return category.name;
      } else {
        return 'Unknown';
      }
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _db.collection('products').doc(id).delete();
      notifyListeners();
    } catch (e) {
      print('Error deleting product: $e');
      throw e;
    }
  }

  Future<String> getBrandImage(String brandId) async {
    if (_brandNames.containsKey(brandId)) {
      return _brandNames[brandId]!;
    } else {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await _db.collection('brands').doc(brandId).get();
      if (snapshot.exists) {
        _brandNames[brandId] = snapshot.data()?['Image'] ?? 'Unknown';
        return _brandNames[brandId]!;
      } else {
        return 'Unknown';
      }
    }
  }

  Future<String> getBrandName(String brandId) async {
    if (_brandNames.containsKey(brandId)) {
      return _brandNames[brandId]!;
    } else {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await _db.collection('brands').doc(brandId).get();
      if (snapshot.exists) {
        _brandNames[brandId] = snapshot.data()?['Name'] ?? 'Unknown';
        return _brandNames[brandId]!;
      } else {
        return 'Unknown';
      }
    }
  }
}
