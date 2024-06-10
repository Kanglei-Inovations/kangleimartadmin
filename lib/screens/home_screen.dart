import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kangleimartadmin/screens/product_review.dart';

import 'add_category_screen.dart';
import 'add_product_screen.dart';
import 'brand_screen.dart';
import 'category_screen.dart';
import 'product_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('KANGLEIMART ADMIN'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            HomeButton(
              icon: Icons.shopping_cart_checkout_outlined,
              label: 'Orders',
              onTap: () {
                Navigator.of(context).pushNamed(BrandScreen.routeName);
              },
            ),
            HomeButton(
              icon: Icons.ads_click,
              label: 'Banners',
              onTap: () {
                Navigator.of(context).pushNamed(BrandScreen.routeName);
              },
            ),
            HomeButton(
              icon: Icons.add_a_photo_outlined,
              label: 'Add Brand',
              onTap: () {
                Navigator.of(context).pushNamed(BrandScreen.routeName);
              },
            ),
            HomeButton(
              icon: Icons.category_outlined,
              label: 'Add Categories',
              onTap: () {
                Navigator.of(context).pushNamed(CategoryScreen.routeName);
              },
            ),
            HomeButton(
              icon: Icons.add_shopping_cart,
              label: 'Add Products',
              onTap: () {
                Navigator.of(context).pushNamed(ProductScreen.routeName);
              },
            ),
            HomeButton(
              icon: Icons.photo_camera_outlined,
              label: 'Media',
              onTap: () {
                Navigator.of(context).pushNamed(ProductScreen.routeName);
              },
            ),
            HomeButton(
              icon: Icons.supervised_user_circle,
              label: 'Customer',
              onTap: () {
                Navigator.of(context).pushNamed(ProductScreen.routeName);
              },
            ),
            HomeButton(
              icon: Icons.supervised_user_circle,
              label: 'Review And Ratings',
              onTap: () {
                Get.to(ProductReviewScreen());
              },
            ),
          ],
        ),
      ),
    );
  }
}

class HomeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  HomeButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(label, style: TextStyle(fontSize: 16)),
        onTap: onTap,
      ),
    );
  }
}
