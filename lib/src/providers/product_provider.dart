
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:dio/dio.dart';
import 'package:tpv_almacen_barcode_scanner/src/models/product_model.dart';


class ProductProvider {

  final String _url = 'http://192.168.0.12:8080/products'; 


 Future<bool> createProduct(BuildContext context, ProductModel product) async {

    try {

      FormData formData = new FormData.fromMap({
            'barcode' : product.barcode,
            'description' : product.description,
            'costprice': product.costprice,
            'salesprice': product.salesprice
          });



      Response resp = await Dio().post('$_url', data: formData);

      if(resp.statusCode == 201){
        return true;
      }

      //return false;
      
    }on Exception catch (e) {
      
      print("No se pudo conectar al servidor: "+e.toString());
      return false;
    }
  }

}