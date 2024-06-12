import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

import '../models/product_model.dart';
import '../widgets/network_image.dart';

class ImageControllerProductScreen extends GetxController {
  static ImageControllerProductScreen get instance => Get.find();

  //Variables
  RxString selectedProductImage = ''.obs;

//Get All Image from product and variations
  List<String> getAllProductImages(ProductModel product) {
    Set<String> images = {};
    images.add(product.images!.first);
    selectedProductImage.value = product.images!.first;
    if(product.images != null){
      images.addAll(product.images!);
    }

    if (product.productVariations != null && product.productVariations!.isNotEmpty) {
      images.addAll(product.productVariations!
          .map((variation) => variation.image)
          .where((image) => image != null && image.isNotEmpty));
    }
    return images.toList();
  }

  void showEnlargedImage(String image) {
    Get.to(
      fullscreenDialog: true,
          () => Scaffold(
        body: Stack(
          children: [
            Center(
              child: PhotoView(
                imageProvider: NetworkImage(image),
                backgroundDecoration: BoxDecoration(
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.black, size: 30),
                onPressed: () => Get.back(),
              ),
            ),
          ],
        ),
      ),
    );
  }



}
