
import 'package:flutter/cupertino.dart';
import 'package:dio/dio.dart';
import 'package:tpv_almacen_barcode_scanner/src/models/product_model.dart';


class ProductProvider {

  final String _url = 'http://192.168.0.12:8080/products'; 


 Future<int> createProduct(BuildContext context, ProductModel product) async {

    try {

      FormData formData = new FormData.fromMap({
            'barcode' : product.barcode,
            'description' : product.description,
            'costprice': product.costprice,
            'salesprice': product.salesprice
          });

      final BaseOptions options = new BaseOptions(method: 'POST', connectTimeout: 3000,sendTimeout: 3000, receiveTimeout: 3000);

      Dio dio = new Dio(options);

      var resp = await dio.post('$_url', data: formData);

      if(resp.statusCode == 200){
        if ( resp.data['additional-data']['alreadyexist'] ){
          return 2; //Product already exist
        }
        if ( resp.data['additional-data']['error'] ){
          return 0; //An error ocurrs in backend system
        }
      }
      
     if (resp.statusCode == 201){
       return 1; //Product created succesfully
     }

     return 0; //An error ocurrs in backend system

    }on DioError catch (e) {
        return -1;
    }
  }
 }