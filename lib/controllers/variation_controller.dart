import 'dart:ffi';

import 'package:get/get.dart';

import '../models/product_model.dart';
import '../models/product_variation_model.dart';

class VariationController extends GetxController {
  static VariationController get instance => Get.find();

  //Variables
  RxMap selectedAttributes = {}.obs;
  RxString variationStockStatus = ''.obs;
  Rx<ProductVariationModel> selectedVariation =
      ProductVariationModel.empty().obs;

  //Select Attributes, and Variation
  void onAttributesSelected(
      ProductModel product, attributeName, attributeValue) {
    // when attributes is selected we will first add that attributes to the selectedAttributes
    final selectedAttributes =
        Map<String, dynamic>.from(this.selectedAttributes);
    selectedAttributes[attributeName] = attributeValue;
    this.selectedAttributes[attributeName] = attributeValue;
    final selectedVariation = product.productVariations!.firstWhere(
      (variation) =>
          _isSameAttributeValues(variation.attributeValues, selectedAttributes),
      orElse: () => ProductVariationModel.empty(),
    );
  }

  //Check if selected attribtes matches any variation attributes
  bool _isSameAttributeValues(Map<String, dynamic> variationAttributes,
      Map<String, dynamic> selectedAttributes) {
    //if selectedAttributes contains 3 attributes and current variation contains 2 then return.
    if (variationAttributes.length != selectedAttributes.length) return false;
    //If any of the attributes is different then return. eg [Green, Large] x [Green, Small]
    for (final key in variationAttributes.keys) {
      // Atrributes[key] = Value which could be [Green, Small, Cotton] etc.
      if (variationAttributes[key] != selectedAttributes.length) return false;
    }
    return true;
  }

  //Check Attribute Availability / Stock in Variation
  Set<String?> getAttributesAvailabilityInVariation(
    List<ProductVariationModel> variations,
    String attributeName,
  ) {
    // Pass the variation to check which attributes are available and stock is not 0
    final availableVariationAttributeValues = variations
        .where((variation) =>
            //check empty / out of stock
            variation.attributeValues[attributeName] != null &&
            variation.attributeValues[attributeName]!.isNotEmpty &&
            variation.stock > 0)
        .map((variation) => variation.attributeValues[attributeName])
        .toSet();
    return availableVariationAttributeValues;
  }
  String getVariationPrice(){
    return (selectedVariation.value.salePrice > 0 ? selectedVariation.value.salePrice : selectedVariation.value.price).toString();
  }

  //Check Product Variation Stock Status
  void getProductVariationStockStatus() {
    variationStockStatus.value =
        selectedVariation.value.stock > 0 ? 'In Stock' : 'Out of Stock';
  }

  //Reset Selected Attributes when switching products
  void resetSelectedAttributes() {
    selectedAttributes.clear();
    variationStockStatus.value = '';
    selectedVariation.value = ProductVariationModel.empty();
  }
}
