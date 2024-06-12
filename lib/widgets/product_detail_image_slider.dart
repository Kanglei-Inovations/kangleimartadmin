import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/image_controller_product_screen.dart';
import '../models/product_model.dart';
import 'network_image.dart';
class ProductDetailImageSlider extends StatelessWidget {
  const ProductDetailImageSlider({
    Key? key,
    required this.product,
    required this.selectedProductImage, // Add selectedProductImage parameter
  }) : super(key: key);

  final ProductModel product;
  final RxString selectedProductImage; // Add selectedProductImage

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ImageControllerProductScreen());
    final images = controller.getAllProductImages(product);
    return Container(
      height: 300,
      child: Stack(
        children: [
          SizedBox(
            height: 400,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Center(
                child: Obx(() {
                  final image = selectedProductImage.value; // Use selectedProductImage
                  return GestureDetector(
                    onTap: () => controller.showEnlargedImage(image),
                    child: NetworkImage(image: image),
                  );
                }),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: SizedBox(
              height: 80,
              child: ListView.separated(
                itemCount: images.length,
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                separatorBuilder: (_, __) => const SizedBox(width: 5),
                itemBuilder: (_, index) => InkWell(
                  onTap: () {
                    selectedProductImage.value = images[index]; // Update selectedProductImage
                  },
                  child: Container(
                    width: 80,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: selectedProductImage.value == images[index] ? Colors.greenAccent : Colors.transparent,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: CachedNetworkImage(
                        progressIndicatorBuilder: (context, url, downloadProgress) =>
                            Center(child: CircularProgressIndicator(value: downloadProgress.progress, color: Colors.green)),
                        imageUrl: images[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

