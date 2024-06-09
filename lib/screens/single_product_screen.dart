import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kangleimartadmin/controllers/variation_controller.dart';
import 'package:provider/provider.dart';
import '../const/enums.dart';
import '../controllers/product_controller.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../widgets/product_detail_image_slider.dart';

class SingleProductScreen extends StatelessWidget {
  final ProductModel product;

  SingleProductScreen({required this.product});

  @override
  Widget build(BuildContext context) {
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    final controller = Get.put(VariationController());
    final productcontroller = Get.put(ProductController());
final salePercentage = productcontroller.calculateSalePercentage(product.price, product.salesPrice);
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Details'),

      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProductDetailImageSlider(product: product),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Price.............
                  Column(
                    children: [
                      Row(
                        children: [
                         
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.greenAccent,
                              ),
                              padding:
                                  EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Text(
                                '${salePercentage}% OFF',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          SizedBox(width: 10),
                          if(product.productType == ProductType.single.toString() && product.salesPrice>0)

                            Text(
                            '₹ ${product.price}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          SizedBox(width: 10),
                          if (product.salesPrice != null &&
                              product.salesPrice! < product.price)
                            Text(
                              '₹ ${productcontroller.getProductPrice(product)}',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                        ],
                      ),

                    ],
                  ),

                  SizedBox(height: 8),
                  //Product Title............
                  Text(
                    product.title,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  //Stock.......................
                  Row(
                    children: [
                      Text('Stock:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        '${product.stock}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
//Brand ..............................................
                  FutureBuilder<String>(
                    future:
                        productProvider.getBrandImage(product.brandId ?? ''),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text('Brand: Loading...',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold));
                      } else if (snapshot.hasError) {
                        return Text('Brand: Error loading brand',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold));
                      } else {
                        // Use CachedNetworkImage to load the brand image
                        return Row(
                          children: [
                            Text(
                              "Brand:",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            CachedNetworkImage(
                              imageUrl: snapshot.data!,
                              width: 30,
                              fit: BoxFit.fill,
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  SizedBox(height: 8),
//Category ........................
                  FutureBuilder<String>(
                    future: productProvider
                        .getCategoryName(product.categoryId ?? ''),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text(
                          'Category: Loading...',
                          style: TextStyle(fontSize: 18),
                        );
                      } else if (snapshot.hasError) {
                        return Text(
                          'Category: Error loading category',
                          style: TextStyle(fontSize: 18),
                        );
                      } else {
                        return Row(
                          children: [
                            Text('Category:',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              '${snapshot.data}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  SizedBox(height: 16),
//Vasriations................................................
// if (controller.selectedVariation.value.id.isNotEmpty)
                    Obx(

                      () => Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.black12,
                        ),

                        child: Padding(

                          padding: const EdgeInsets.all(8.0),
                          child: Column(

                            children: [

                              Row(
                                children: [
                                  Text("Variation", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),),
                                  SizedBox(width: 10,),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Row(
                                        children: [
                                          Text("Price: ", style: TextStyle(fontWeight: FontWeight.bold),),
                                          if (controller.selectedVariation.value.salePrice > 0)
                                          Text('Rs. ${controller.getVariationPrice()}  ', style: TextStyle(fontSize: 14,decoration: TextDecoration.lineThrough, ),),
                                          Text('Rs. ${controller.getVariationPrice()}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),)
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text("Stock:",style: TextStyle(fontWeight: FontWeight.bold),),
                                          Text(controller.variationStockStatus.value,style: TextStyle(fontWeight: FontWeight.bold),),
                                        ],
                                      ),

                                    ],
                                  ),
                                ],
                              ),
                              Text("This Product variable description. Change function get from firebase this is demo")
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (product.productType == ProductType.variable.toString())
                    Column(
                      children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: product.productAttributes
                                    ?.map((attribute) => Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${attribute.name}',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                           Obx(
                                               () =>Wrap(
                                                 spacing: 8,
                                                 children: attribute.values!
                                                     .map((attributeValue) {
                                                   final isSelected = controller
                                                       .selectedAttributes[
                                                   attribute.name] ==
                                                       attributeValue;
                                                   final available = controller
                                                       .getAttributesAvailabilityInVariation(
                                                     product
                                                         .productVariations!,
                                                     attribute.name!,
                                                   )
                                                       .contains(attributeValue);

                                                   return StatefulBuilder(
                                                     builder: (context, setState) {
                                                       return FilterChip(
                                                         selected: isSelected,
                                                         onSelected: available
                                                             ? (selected) {
                                                           setState(() {
                                                             if (selected &&
                                                                 available) {
                                                               controller
                                                                   .onAttributesSelected(
                                                                 product,
                                                                 attribute
                                                                     .name ??
                                                                     '',
                                                                 attributeValue,
                                                               );
                                                             }
                                                           });
                                                         }
                                                             : null,
                                                         label:
                                                         Text(attributeValue),
                                                       );
                                                     },
                                                   );
                                                 }).toList(),
                                               )
                                           )
                                          ],
                                        ))
                                    .toList() ??
                                [])
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

