import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/brand_model.dart';

class BrandProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  List<BrandModel> _brands = [];

  List<BrandModel> get brands {
    return [..._brands];
  }

  Future<void> addBrand(BrandModel brand, String imagePath) async {
    try {
      // Upload the image to Firebase Storage
      String imageUrl = await _uploadImage(imagePath);

      // Add the brand to Firestore with the image URL
      DocumentReference docRef = await _db.collection('brands').add({
        'name': brand.name,
        'image': imageUrl,
        'isFeatured': brand.isFeatured,
        'productsCount': brand.productsCount,
      });

      // Update the local list of brands
      _brands.add(BrandModel(
        id: docRef.id,
        name: brand.name,
        image: imageUrl,
        isFeatured: brand.isFeatured,
        productsCount: brand.productsCount,
      ));
      notifyListeners();
    } catch (e) {
      print('Error adding brand: $e');
      throw e;
    }
  }

  Future<String> _uploadImage(String imagePath) async {
    File file = File(imagePath);
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = _storage.ref().child('brand_images').child(fileName);
    UploadTask uploadTask = ref.putFile(file);
    TaskSnapshot snapshot = await uploadTask.whenComplete(() => {});
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}
