import 'package:flutter/material.dart';
import 'dart:math';

import '../models/product_attribute_model.dart';
import '../models/product_variation_model.dart';




class ProductVariationWidget extends StatefulWidget {
  @override
  _ProductVariationWidgetState createState() => _ProductVariationWidgetState();
}

class _ProductVariationWidgetState extends State<ProductVariationWidget> {
  final List<ProductAttributeModel> attributes = [];
  final List<ProductVariationModel> variations = [];
  final TextEditingController attributeNameController = TextEditingController();
  final TextEditingController attributeValuesController = TextEditingController();

  @override
  void dispose() {
    attributeNameController.dispose();
    attributeValuesController.dispose();
    super.dispose();
  }

  void addAttribute() {
    final name = attributeNameController.text.trim();
    final values = attributeValuesController.text.split(',').map((e) => e.trim()).toList();

    if (name.isNotEmpty && values.isNotEmpty) {
      setState(() {
        attributes.add(ProductAttributeModel(name: name, values: values));
      });
      attributeNameController.clear();
      attributeValuesController.clear();
    }
  }

  void removeAttribute(int index) {
    setState(() {
      attributes.removeAt(index);
    });
  }

  void generateVariations() {
    final List<ProductVariationModel> newVariations = [];
    final Map<String, List<String>> attributeMap = {for (var attr in attributes) attr.name!: attr.values!};
    final combinations = generateCombinations(attributeMap);

    for (var combination in combinations) {
      newVariations.add(ProductVariationModel(id: generateId(), attributeValues: combination));
    }

    setState(() {
      variations.clear();
      variations.addAll(newVariations);
    });
  }

  List<Map<String, String>> generateCombinations(Map<String, List<String>> attributeMap) {
    if (attributeMap.isEmpty) return [];

    final keys = attributeMap.keys.toList();
    final List<Map<String, String>> results = [];

    void combine(int depth, Map<String, String> current) {
      if (depth == keys.length) {
        results.add(Map<String, String>.from(current));
        return;
      }

      final key = keys[depth];
      for (var value in attributeMap[key]!) {
        current[key] = value;
        combine(depth + 1, current);
      }
    }

    combine(0, {});
    return results;
  }

  String generateId() {
    return Random().nextInt(1000000).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: Text("sasas"),),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: attributeNameController,
                    decoration: InputDecoration(labelText: 'Attribute Name (e.g., Color)'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: attributeValuesController,
                    decoration: InputDecoration(labelText: 'Attributes (e.g., Green, Blue, Red)'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: addAttribute,
                ),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: attributes.length,
              itemBuilder: (context, index) {
                final attribute = attributes[index];
                return ListTile(
                  title: Text('${attribute.name} (${attribute.values!.join(', ')})'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => removeAttribute(index),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: generateVariations,
              child: Text('Generate Variations'),
            ),
            SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              itemCount: variations.length,
              itemBuilder: (context, index) {
                final variation = variations[index];
                return ExpansionTile(
                  title: Text('Variation ${index + 1}: ${variation.attributeValues.entries.map((e) => '${e.key}: ${e.value}').join(', ')}'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          TextField(
                            decoration: InputDecoration(labelText: 'SKU'),
                            onChanged: (value) => variation.sku = value,
                          ),
                          TextField(
                            decoration: InputDecoration(labelText: 'Image URL'),
                            onChanged: (value) => variation.image = value,
                          ),
                          TextField(
                            decoration: InputDecoration(labelText: 'Description'),
                            onChanged: (value) => variation.description = value,
                          ),
                          TextField(
                            decoration: InputDecoration(labelText: 'Price'),
                            keyboardType: TextInputType.number,
                            onChanged: (value) => variation.price = double.parse(value),
                          ),
                          TextField(
                            decoration: InputDecoration(labelText: 'Sale Price'),
                            keyboardType: TextInputType.number,
                            onChanged: (value) => variation.salePrice = double.parse(value),
                          ),
                          TextField(
                            decoration: InputDecoration(labelText: 'Stock'),
                            keyboardType: TextInputType.number,
                            onChanged: (value) => variation.stock = int.parse(value),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

