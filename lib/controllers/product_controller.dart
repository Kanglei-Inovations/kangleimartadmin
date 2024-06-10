import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kangleimartadmin/models/product_model.dart';

import '../const/enums.dart';

class ProductController extends GetxController {
  String getProductPrice(ProductModel product) {
    double smallestPrice = double.infinity;
    double largestPrice = 0.0;
    if (product.productType == ProductType.single.toString()) {
      return (product.salesPrice > 0 ? '₹${product.salesPrice}' : '₹${product.price}')
          .toString();
    } else {
      for (var variation in product.productVariations!) {
        double priceToConsider =
            variation.salePrice > 0.0 ? variation.salePrice : variation.price;
        if (priceToConsider < smallestPrice) {
          smallestPrice = priceToConsider;
        }
        if (priceToConsider > largestPrice) {
          largestPrice = priceToConsider;
        }
      }
      if (smallestPrice.isEqual(largestPrice)) {
        return largestPrice.toString();
      } else {
        return '₹$smallestPrice - ₹$largestPrice';
      }
    }
  }

  String? calculateSalePercentage(double originalPrice, double? salePrice) {
    if (salePrice == null || salePrice <= 0.0) return null;
    if (originalPrice <= 0) return null;
    double percentage = ((originalPrice - salePrice) / originalPrice) * 100;
    return percentage.toStringAsFixed(0);
  }
  //Check Product Variation Stock Status
  String getProductStockStatus(int stock) {
    return stock > 0 ? 'In Stock' : 'Out of Stock';
  }
  //Check Product Variation Stock Status
  Status(int stock) {
    return stock > 0 ? Colors.green : 'Colors.red';
  }

}
