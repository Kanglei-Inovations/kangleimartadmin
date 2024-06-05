import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/brand_provider.dart';
import '../models/brand_model.dart';
import 'add_brand_screen.dart';

class BrandScreen extends StatelessWidget {
  static const routeName = '/brands';

  @override
  Widget build(BuildContext context) {
    final brands = Provider.of<BrandProvider>(context).brands;
    return Scaffold(
      appBar: AppBar(
        title: Text('Brands'),
      ),
      body: ListView.builder(
        itemCount: brands.length,
        itemBuilder: (context, index) {
          final brand = brands[index];
          return ListTile(
            title: Text(brand.name),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(brand.image),
            ),
            onTap: () {
              // Navigate to brand details screen
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(AddBrandScreen.routeName);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
