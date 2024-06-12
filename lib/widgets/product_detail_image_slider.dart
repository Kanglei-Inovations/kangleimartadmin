import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/image_controller_product_screen.dart';
import '../models/product_model.dart';
import 'network_image.dart';

class ProductDetailImageSlider extends StatelessWidget {
  ProductDetailImageSlider({
    super.key,
    required this.product,
    required this.selectedProductImage,
  });

  final ProductModel product;
  final RxString selectedProductImage;
  final ScrollController _scrollController = ScrollController(); // Add ScrollController

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ImageControllerProductScreen());
    final images = controller.getAllProductImages(product);

    // Scroll to the selected image index when selectedProductImage changes
    selectedProductImage.listen((image) {
      final index = images.indexOf(image);
      if (index != -1) {
        _scrollController.animateTo(
          index * 85.0, // Approximate width of each item + spacing
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          SizedBox(
            height: 400,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Center(
                child: Obx(() {
                  final image = selectedProductImage.value;
                  return GestureDetector(
                    onTap: () => controller.showEnlargedImage(image),
                    child: NetworkImageWidget(image: image),
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
                controller: _scrollController, // Attach the ScrollController
                itemCount: images.length,
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                separatorBuilder: (_, __) => const SizedBox(width: 5),
                itemBuilder: (_, index) {
                  return Obx(() {
                    return InkWell(
                      onTap: () {
                        selectedProductImage.value = images[index];
                        print('${images[index]} = ${selectedProductImage.value}');
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
                          child: NetworkImageWidget(image: images[index]),
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
