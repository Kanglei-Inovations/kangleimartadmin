import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';
import 'add_product_screen.dart';
import 'single_product_screen.dart'; // Import the single product screen

class ProductScreen extends StatelessWidget {
  static const routeName = '/products';

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text('Products'),
      ),
      body: StreamBuilder<List<ProductModel>>(
        stream: Provider.of<ProductProvider>(context).streamProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No products available.'));
          } else {
            final products = snapshot.data!;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                double discountPercentage = 0;
                if (product.price > 0) {
                  discountPercentage =
                      ((product.price - product.salesPrice) / product.price) * 100;
                }

                return FutureBuilder<String>(
                  future: Provider.of<ProductProvider>(context, listen: false)
                      .getCategoryName(product.categoryId ?? ''),
                  builder: (context, categorySnapshot) {
                    if (categorySnapshot.connectionState == ConnectionState.waiting) {
                      return ListTile(
                        title: Text(product.title),
                        subtitle: Text('Loading category...'),
                      );
                    } else if (categorySnapshot.hasError) {
                      return ListTile(
                        title: Text(product.title),
                        subtitle: Text('Error loading category'),
                      );
                    } else {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SingleProductScreen(product: product),
                            ),
                          );
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: product.images != null &&
                                product.images!.isNotEmpty
                                ? NetworkImage(product.images!.first)
                                : null,
                            child: product.images == null || product.images!.isEmpty
                                ? Icon(Icons.image)
                                : null,
                          ),
                          title: Text(product.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Price:  ${product.price.toStringAsFixed(2)} ',
                                      style: TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        color: Colors.red,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' ₹ ${product.salesPrice.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    if (discountPercentage > 0)
                                      TextSpan(
                                        text:
                                        ' (${discountPercentage.toStringAsFixed(1)}% OFF)',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Text('Stock: ${product.stock}'),
                              Text('Category: ${categorySnapshot.data ?? 'N/A'}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: product.isFeatured
                                ? Icon(Icons.remove_red_eye_outlined, color: Colors.green,)
                                : Icon(Icons.remove_red_eye_outlined, color: Colors.red,),
                            onPressed: () async {
                              final newValue = !product.isFeatured;
                              await Provider.of<ProductProvider>(context, listen: false)
                                  .updateIsFeatured(product.id, newValue);
                            },
                          ),

                        ),
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(AddProductScreen.routeName);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
