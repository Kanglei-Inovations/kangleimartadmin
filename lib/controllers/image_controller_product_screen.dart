import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/product_model.dart';

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
          () => Dialog.fullscreen(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: CachedNetworkImage(imageUrl: image),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Close'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



}
