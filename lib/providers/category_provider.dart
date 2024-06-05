import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/category_model.dart';

class CategoryProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  List<CategoryModel> _categories = [];

  List<CategoryModel> get categories => _categories;

  Stream<List<CategoryModel>> streamCategories() {
    return _db.collection('categories').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return CategoryModel.fromSnapshot(doc);
      }).toList();
    });
  }

  Future<void> addCategory(CategoryModel category) async {
    try {
      await _db.collection('categories').add(category.toJson());
      notifyListeners();
    } catch (e) {
      print('Error adding category: $e');
      throw e;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _db.collection('categories').doc(id).delete();
      notifyListeners();
    } catch (e) {
      print('Error deleting category: $e');
      throw e;
    }
  }

  Future<void> updateCategory(String id, Map<String, dynamic> data) async {
    try {
      await _db.collection('categories').doc(id).update(data);
      notifyListeners();
    } catch (e) {
      print('Error updating category: $e');
      throw e;
    }
  }

  Future<String> uploadImage(String imagePath) async {
    File file = File(imagePath);
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = _storage.ref().child('category_images').child(fileName);
    UploadTask uploadTask = ref.putFile(file);
    TaskSnapshot snapshot = await uploadTask.whenComplete(() => {});
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}
