import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/brand_model.dart';

class BrandProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  List<BrandModel> _brands = [];
  Map<String, String> _brandImages = {}; // Cache brand images

  List<BrandModel> get brands => _brands;

  Stream<List<BrandModel>> streamBrands() {
    return _db.collection('brands').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return BrandModel.fromSnapshot(doc);
      }).toList();
    });
  }

  Future<void> addBrand(BrandModel brand) async {
    try {
      await _db.collection('brands').add(brand.toJson());
      notifyListeners();
    } catch (e) {
      print('Error adding brand: $e');
      throw e;
    }
  }

  Future<void> deleteBrand(String id) async {
    try {
      await _db.collection('brands').doc(id).delete();
      notifyListeners();
    } catch (e) {
      print('Error deleting brand: $e');
      throw e;
    }
  }

  Future<void> updateBrand(String id, Map<String, dynamic> data) async {
    try {
      await _db.collection('brands').doc(id).update(data);
      notifyListeners();
    } catch (e) {
      print('Error updating brand: $e');
      throw e;
    }
  }

  Future<String> uploadImage(String imagePath) async {
    File file = File(imagePath);
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = _storage.ref().child('brand_images').child(fileName);
    UploadTask uploadTask = ref.putFile(file);
    TaskSnapshot snapshot = await uploadTask.whenComplete(() => {});
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }
  Future<String> getBrandImage(String brandId) async {
    if (_brandImages.containsKey(brandId)) {
      return _brandImages[brandId]!;
    } else {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
      await _db.collection('brands').doc(brandId).get();
      if (snapshot.exists) {
        BrandModel brand = BrandModel.fromSnapshot(snapshot);
        _brandImages[brandId] = brand.image;
        return brand.image;
      } else {
        return '';
      }
    }
  }

}
