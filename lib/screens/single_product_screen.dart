import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';

class SingleProductScreen extends StatelessWidget {
  final ProductModel product;

  SingleProductScreen({required this.product});



  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Product Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 400, // Adjust the height as needed
              color: Colors.redAccent,
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CachedNetworkImage(
                          imageUrl: product.images!.first,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 100, // Adjust the height as needed
                    child: ListView.separated(
                      itemCount: product.images?.length ?? 0, // Ensure itemCount matches the number of images
                      scrollDirection: Axis.horizontal,
                      separatorBuilder: (_, __) => const SizedBox(width: 5),
                      itemBuilder: (_, index) {
                        return CachedNetworkImage(
                          imageUrl: product.images![index],
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [


                      Text(
                        '₹ ${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      SizedBox(width: 10),
                      if (product.salesPrice != null && product.salesPrice! < product.price)
                        Text(
                          '₹ ${product.salesPrice!.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      SizedBox(width: 10),
                      if (productProvider.getDiscountPercentage(product) > 0)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.greenAccent,
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text(
                            '${productProvider.getDiscountPercentage(product).toStringAsFixed(1)}% OFF',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: 8),
                  Text(
                    product.title,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                  Text(
                  'Stock:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                  ),
                      SizedBox(width: 10,),
                      Text(
                        '${product.stock}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  FutureBuilder<String>(
                    future: productProvider.getBrandImage(product.brandId ?? ''),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text(
                          'Brand: Loading...',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)

                        );
                      } else if (snapshot.hasError) {
                        return Text(
                          'Brand: Error loading brand',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)

                        );
                      } else {
                        // Use CachedNetworkImage to load the brand image
                        return Row(
                          children: [
                            Text("Brand:",style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                            SizedBox(width: 10,),
                            CachedNetworkImage(imageUrl: snapshot.data!, width: 30,fit: BoxFit.fill,),
                          ],
                        );
                      }
                    },
                  ),


                  SizedBox(height: 8),

                  FutureBuilder<String>(
                    future: productProvider.getCategoryName(product.categoryId ?? ''),
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
                            Text(
                              'Category:',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                            ),
                            SizedBox(width: 10,),
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
                  Text(
                    'Variations:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: 200, // Adjust the height as needed
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: product.productVariations?.length ?? 0,
                      itemBuilder: (context, index) {
                        final variation = product.productVariations![index];
                        return ListTile(
                          title: Text('Attributes: ${variation.attributeValues.entries.map((e) => '${e.key}:${e.value}').join(', ')}'),
                          subtitle: Text('Price: ₹${variation.price.toStringAsFixed(2)}'),
                        );
                      },
                    ),
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
