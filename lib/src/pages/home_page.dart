import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:tpv_almacen_barcode_scanner/src/models/product_model.dart';
import 'package:tpv_almacen_barcode_scanner/src/providers/product_provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FocusNode myFocusNode;
  final _formKey = GlobalKey<FormState>();
  final _productProvider = new ProductProvider();

  ProductModel product = new ProductModel();

  String _barcode ="";

  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
 
  clearTextInput(){
    _barcode = "";
    _descriptionController.clear();
    _priceController.clear();
  }

  Future _scanBarcode() async{
   
    String barcode = await FlutterBarcodeScanner.scanBarcode("#004297", "Cancelar", false, ScanMode.BARCODE);
    setState(() {
      if(barcode == '-1'){
        _barcode = "";
        return;
      }
      _barcode = barcode;
      product.barcode = barcode;
    });
  }

  @override
  void initState() {
    super.initState();

    myFocusNode = FocusNode();
  }

   @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    myFocusNode.dispose();

    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(  
      appBar: AppBar(
        title: Text('Productos'),
      ),
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height*0.8,
          width: 300.0,
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                _createBarcode(),
                _createDescription(),
                _createPrice(),
                _createSaveProductButton(context),
                SizedBox(height: MediaQuery.of(context).size.height*0.32),
                _createScanButton(context),
              ],
            ),
          ),
        )
      ),
    );
  }

  Widget _createBarcode() {
    return Container(
      margin: EdgeInsets.only(bottom:30.0),
      child: Text(
          _barcode,
          textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 40.0
          ),
        ),
    );
  }

  Widget _createDescription() {
   return Container(
      margin: EdgeInsets.only(bottom: 30.0),
      child: TextFormField(
        controller: _descriptionController,
        decoration: InputDecoration(
          labelText: "Descripción",
          contentPadding: EdgeInsets.all(10.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0)
          ),
        ),
        onSaved: ( value ) => { product.description = value },
        validator: ( descriptionValue ){
          if (descriptionValue.isEmpty ){
            return 'Ingrese descripción';
          }
          return null;
        },
        onChanged: ( descriptionValue ) => setState(() {
          product.description = descriptionValue;
          })
      ),
    );
  }

    Widget _createPrice() {
    return Container(
        margin: EdgeInsets.only(bottom: 30.0),
        child: TextFormField(
          keyboardType: TextInputType.number,
          controller: _priceController,
          decoration: InputDecoration(
            labelText: "Precio",
            contentPadding: EdgeInsets.all(10.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0)
            ),
          ),
          onSaved: ( value ) => {
            product.salesprice = double.parse(value)
           },
          validator: ( priceValue ){
            if (priceValue.isEmpty ){
              return 'Ingrese precio';
            }
              return null;
          },
          onChanged: ( priceValue ) => setState(() {
            product.costprice = double.parse(priceValue);
            product.salesprice = double.parse(priceValue);
            })
        ),
      );
    }

 Widget _createSaveProductButton(BuildContext context) {
    return RaisedButton(
      autofocus: true,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.blue),
        borderRadius: BorderRadius.circular(5.0)
        ),
      onPressed: () => _submit(context),
      padding: EdgeInsets.all(10.0),
      color: Colors.white,
        child: Text('Guardar', 
          style: TextStyle(
            fontSize: 18, 
            color: Colors.blue,
            )
        )
        );
  }

 Widget _createScanButton(BuildContext context) {
    return RaisedButton.icon(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0)

        ),
      onPressed: () => _scanBarcode(),
      padding: EdgeInsets.all(10.0),
      color: Colors.blue,
        icon: Icon(Icons.settings_overscan, color: Colors.white),
        label: Text('Escanear', style: TextStyle(fontSize: 18.0, color: Colors.white),),

        );
  }

 _submit(BuildContext context) async{
      if( !_formKey.currentState.validate() ) return;

   _formKey.currentState.save();

  _productProvider.createProduct(context, product).then((value) {
  if (  value == true ){
      //TODO: Clear inputs fields 
      clearTextInput();
      setState(() {
        product = new ProductModel();
      });
  }else{
    //TODO: Show error
  }

  });
 }
}
