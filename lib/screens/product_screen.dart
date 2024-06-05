import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../providers/product_provider.dart';
import 'add_product_screen.dart';

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
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final products = snapshot.data!;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  title: Text(product.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Price: \$${product.price.toStringAsFixed(2)}'),
                      Text('Stock: ${product.stock}'),
                      Text('Brand: ${product.brand?.name ?? 'N/A'}'),
                      Text('Category: ${product.categoryId ?? 'N/A'}'),
                    ],
                  ),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(product.thumbnail),
                  ),
                  onTap: () {
                    // Navigate to product details screen
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
