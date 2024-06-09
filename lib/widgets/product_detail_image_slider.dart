import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/image_controller_product_screen.dart';
import '../models/product_model.dart';

class ProductDetailImageSlider extends StatelessWidget {
  const ProductDetailImageSlider({
    Key? key,
    required this.product,
  }) : super(key: key);

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ImageControllerProductScreen());
    final images = controller.getAllProductImages(product);
    return Container(
      height: 400, // Adjust the height as needed
      child: Stack(
        children: [
          SizedBox(
            height: 400,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Center(
                child: Obx(
                        () {
                  final image = controller.selectedProductImage.value;
                  return GestureDetector(
                    onTap: () => controller.showEnlargedImage(image),
                    child: CachedNetworkImage(imageUrl: image,
                        progressIndicatorBuilder: (_, __, downloadProgress) =>
                            Center(child: CircularProgressIndicator(value: downloadProgress.progress, color: Colors.green))

                    ),
                  );
                }),
              ),
            ),
          ),
          // Other child widgets like ListView for thumbnails can go here
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: SizedBox(
              height: 80, // Adjust the height as needed
              child: ListView.separated(
                itemCount: images.length,
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                separatorBuilder: (_, __) => const SizedBox(width: 5),
                itemBuilder: (_, index) => Obx(
                    (){
                      final imageSelected =  controller.selectedProductImage.value == images[index];
                      return  InkWell(
                        onTap: (){
                          controller.selectedProductImage.value = images[index];
                        },
                        child: Container(
                          width: 80,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: imageSelected ? Colors.greenAccent : Colors.transparent),
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
                      );
                    }
                )
              ),
            ),
          ),
        ],
      ),
    );
  }
}
