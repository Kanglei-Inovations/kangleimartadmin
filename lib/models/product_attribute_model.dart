class ProductAttributeModel {
  String? name;
  List<String>? values;

  ProductAttributeModel({this.name, required this.values});

  //json format
  Map<String, dynamic> toJson() => {
    'Name': name,
    'Values': values,
  };

  // map json document snapshot from firebase to model
  factory ProductAttributeModel.fromJson(Map<String, dynamic> document) {
    final data = document;
    if (data.isEmpty) return ProductAttributeModel(values: []);

    return ProductAttributeModel(
      name: data.containsKey('Name') ? data['Name']: '',
      values: List<String>.from(data['Values']),
    );
  }
}