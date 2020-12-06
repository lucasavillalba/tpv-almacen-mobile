import 'package:flutter/material.dart';
import 'package:tpv_almacen_barcode_scanner/src/pages/home_page.dart';

Map<String, WidgetBuilder> getApplicationsRoutes(){

  return <String, WidgetBuilder>{
    'home'    : ( BuildContext context ) => HomePage(),
  };
}