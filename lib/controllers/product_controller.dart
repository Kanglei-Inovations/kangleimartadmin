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

  String? calculateSalePercentage(ProductModel product) {
    double smallestPercentage = double.infinity;
    double largestPercentage = 0.0;

    void updatePercentages(double originalPrice, double salePrice) {
      if (originalPrice <= 0 || salePrice <= 0) return;
      double percentage = ((originalPrice - salePrice) / originalPrice) * 100;
      if (percentage < smallestPercentage) {
        smallestPercentage = percentage;
      }
      if (percentage > largestPercentage) {
        largestPercentage = percentage;
      }
    }

    if (product.productType == ProductType.single.toString()) {
      updatePercentages(product.price, product.salesPrice);
      return smallestPercentage < double.infinity ? '${smallestPercentage
          .toStringAsFixed(0)}%' : null;
    } else {
      for (var variation in product.productVariations!) {
        updatePercentages(variation.price, variation.salePrice);
      }
      if (smallestPercentage == largestPercentage) {
        return '${largestPercentage.toStringAsFixed(0)}%';
      } else {
        return '${smallestPercentage.toStringAsFixed(0)}% - ${largestPercentage
            .toStringAsFixed(0)}%';
      }
    }
  }
  //Check Product Variation Stock Status

  String getProductStockStatus(ProductModel product) {
    if (product.productType == ProductType.single.toString()) {
      print("Product Stock: ${product.stock}");
      return product.stock > 0 ? 'In Stock' : 'Out of Stock';
    } else if (product.productType == ProductType.variable.toString()) {
      int totalStock = product.productVariations!.fold(0, (total, variation) => total + variation.stock);
      print("Product Stock: $totalStock");
      return totalStock > 0 ? 'In Stock' : 'Out of Stock';
    } else {
      return 'Unknown Product Type';
    }
  }
  //Check Product Variation Stock Status
  Status(ProductModel product) {
    if (product.productType == ProductType.single.toString()) {
      return product.stock > 0 ? Colors.green : Colors.red;
    } else if (product.productType == ProductType.variable.toString()) {
      int totalStock = product.productVariations!.fold(0, (total, variation) => total + variation.stock);
      return totalStock > 0 ? Colors.green : Colors.red;
    } else {
      return 'Unknown Product Type';
    }

  }

}
