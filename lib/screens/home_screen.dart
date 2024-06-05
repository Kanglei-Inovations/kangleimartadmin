import 'package:flutter/material.dart';

import 'add_product_screen.dart';
import 'brand_screen.dart';
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
            InkWell(
              onTap: (){
                Navigator.of(context).pushNamed(BrandScreen.routeName);
              },
              child: Row(
                children: [
                  Icon(Icons.add_a_photo_outlined),
                  Text("Add Brand")
                ],
              ),
            ),
            SizedBox(height: 20,),
            InkWell(
              onTap: (){
                Navigator.of(context).pushNamed(ProductScreen.routeName);
              },
              child: Row(
                children: [
                  Icon(Icons.add_shopping_cart),

                  Text("Add Products")
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
