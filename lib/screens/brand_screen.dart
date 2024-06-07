import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/brand_provider.dart';
import '../models/brand_model.dart';
import 'add_brand_screen.dart';

class BrandScreen extends StatelessWidget {
  static const routeName = '/brands';

  @override
  Widget build(BuildContext context) {
    final brandProvider = Provider.of<BrandProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Brands'),
      ),
      body: StreamBuilder<List<BrandModel>>(
        stream: brandProvider.streamBrands(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading brands'));
          }
          final brands = snapshot.data ?? [];
          return ListView.builder(
            itemCount: brands.length,
            itemBuilder: (context, index) {
              final brand = brands[index];
              return BrandItem(brand: brand);
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

class BrandItem extends StatelessWidget {
  final BrandModel brand;

  const BrandItem({required this.brand});

  @override
  Widget build(BuildContext context) {
    final brandProvider = Provider.of<BrandProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      elevation: 4,
      child: ListTile(
        leading: brand.image.isNotEmpty
            ? CachedNetworkImage( imageUrl:
          brand.image,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        )
            : Icon(Icons.category, size: 50),
        title: Text(brand.name, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: GestureDetector(
          onTap: () async {
            await brandProvider.updateBrand(brand.id, {'isFeatured': !(brand.isFeatured ?? false)});
          },
          child: Row(
            children: [
              Text('Featured: '),
              Icon(
                brand.isFeatured ?? false ? Icons.check_circle : Icons.check_circle_outline,
                color: brand.isFeatured ?? false ? Colors.green : Colors.grey,
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                // Navigate to edit brand screen
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await brandProvider.deleteBrand(brand.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
