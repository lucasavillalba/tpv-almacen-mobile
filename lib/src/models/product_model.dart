import 'dart:convert';

ProductModel productModelFromJson(String str) => ProductModel.fromJson(json.decode(str));

String productModelToJson(ProductModel data) => json.encode(data.toJson());

class ProductModel {
    ProductModel({
        this.barcode,
        this.description,
        this.costprice,
        this.salesprice,
    });

    String barcode;
    String description;
    int costprice;
    int salesprice;

    factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        barcode: json["barcode"],
        description: json["description"],
        costprice: json["costprice"],
        salesprice: json["salesprice"],
    );

    Map<String, dynamic> toJson() => {
        "barcode": barcode,
        "description": description,
        "costprice": costprice,
        "salesprice": salesprice,
    };
}
