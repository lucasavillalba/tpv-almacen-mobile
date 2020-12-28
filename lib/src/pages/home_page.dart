import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:tpv_almacen_barcode_scanner/src/models/product_model.dart';
import 'package:tpv_almacen_barcode_scanner/src/providers/product_provider.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  FocusNode scanButtonFocus;
  FocusNode descriptionTextFieldFocus;
  final _formKey = GlobalKey<FormState>();
  final _productProvider = new ProductProvider();

  ProductModel product = new ProductModel();

  String _barcode ="";
  bool _isPressed = false, _animatingReveal = false;
  int _buttonSaveState = 0;
  double _buttonSaveWith = double.infinity;
  GlobalKey _buttonKey = GlobalKey();
  bool _isButtonDisabled = true;

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
      descriptionTextFieldFocus.requestFocus();
    });
  }

  @override
  void initState() {
    super.initState();

    scanButtonFocus = FocusNode();
    descriptionTextFieldFocus = FocusNode();

    _descriptionController.addListener(_enableSaveButton);
    _priceController.addListener(_enableSaveButton);
  }

   @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    scanButtonFocus.dispose();
    descriptionTextFieldFocus.dispose();
    
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  @override
  void deactivate() {
    reset();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(  
      appBar: AppBar(
        title: Text('Productos'),
      ),
      body: Builder(
        builder: (BuildContext context) {
          return Center(
          child: Container(
            height: MediaQuery.of(context).size.height*0.8,
            padding: EdgeInsets.symmetric(horizontal: 20.0),
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
        );
      }),
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
        focusNode: descriptionTextFieldFocus,
        textInputAction: TextInputAction.next,
        textCapitalization: TextCapitalization.characters,
        controller: _descriptionController,
        decoration: InputDecoration(
          labelText: "Descripción",
          contentPadding: EdgeInsets.all(10.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0)
          ),
        ),
        onSaved: ( value ) => { product.description = value },
        validator: ( descriptionValue ) {
          if (descriptionValue.isEmpty ){
            return 'Ingrese descripción';
          }
          return null;
        }, 
      ),
    );
  }

    Widget _createPrice() {
    return Container(
        margin: EdgeInsets.only(bottom: 30.0),
        child: TextFormField(
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          controller: _priceController,
          decoration: InputDecoration(
            labelText: "Precio",
            contentPadding: EdgeInsets.all(10.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0)
            ),
          ),
          onSaved: ( value ) => {
            product.salesprice =  product.costprice = double.parse(value)
           },
          validator: ( priceValue ){
            if (priceValue.isEmpty ){
              return 'Ingrese precio';
            }
              return null;
          },
        ),
      );
    }

 Widget _createSaveProductButton(BuildContext context) {
    return Center(
      child: Container(
        width: _buttonSaveWith,
        child: RaisedButton(
          key: _buttonKey,
          child: buildButtonChild(),
          elevation: calculateElevation(),
          onHighlightChanged: (isPressed){
            setState((){
              _isPressed = isPressed;
              if (_buttonSaveState == 0 ){
                _animateButton();
              }
              });
          },
          shape: RoundedRectangleBorder(
            side: _isButtonDisabled == true ? BorderSide(color: Colors.grey[600]) : BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.circular(5.0)
            ),
          onPressed: _isButtonDisabled == true ? null : () => _submit(context),
          padding: EdgeInsets.all(0.0),
          color: _isButtonDisabled == true ? Colors.grey[600] : Colors.blue,
        ),
      ),
    );
  }

 Widget _createScanButton(BuildContext context) {
    return RaisedButton.icon(
      focusNode: scanButtonFocus,
      shape: RoundedRectangleBorder(
        
        borderRadius: BorderRadius.circular(5.0)

        ),
      onPressed: () => _scanBarcode(),
      padding: EdgeInsets.all(10.0),
      color: Colors.blue,
        icon: Icon(Icons.settings_overscan, color: Colors.white),
        label: Text('Escanear',  style: TextStyle(fontSize: 18.0, color: Colors.white),),
        );
  }

  _enableSaveButton(){
    if (_descriptionController.text != "" && _priceController.text != "" ){
      setState((){
        _isButtonDisabled = false;
      });
      return ;
    } 
    setState((){
        _isButtonDisabled = true;
    });
  }
 _submit(BuildContext context) async{

   // Remove focus from keyboard
   FocusManager.instance.primaryFocus.unfocus();

   // Validate form
   if( !_formKey.currentState.validate() ) return;

   _formKey.currentState.save();

  // Save product on backend system. Possible returns values are: 
  // -1: Unable to connect to server
  //  0: Product was not created
  //  1: Product created succesfully
  //  2: Product already exist
  _productProvider.createProduct(context, product).then((value) {

    switch(value) { 
      // Unable to connect to server
      case -1: { 
         final snackBar = SnackBar( 
          backgroundColor: Colors.red,
          content: Text('No se pudo conectar al servidor', textAlign: TextAlign.center),
        );
        Scaffold.of(context).showSnackBar(snackBar);
      } 
      break; 
      // Product was not created
      case 0: { 
        setState(() {
          _buttonSaveState = -1;
        });
        final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text('No fue posible crear el producto', textAlign: TextAlign.center),
        );
        Scaffold.of(context).showSnackBar(snackBar);
      } 
      break; 

      // Product created succesfully
      case 1: { 
        setState(() {
          product = new ProductModel();
          _buttonSaveState = 2;
          scanButtonFocus.requestFocus();
          clearTextInput();
        });
        final snackBar = SnackBar(
          backgroundColor: Colors.green,
          content: Text('Producto creado correctamente', textAlign: TextAlign.center),
        );
        Scaffold.of(context).showSnackBar(snackBar);
      } 
      break; 
      
      // roduct already exist
      case 2: { 
        final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text('¡Ya existe el producto escaneado!', textAlign: TextAlign.center),
        );
        Scaffold.of(context).showSnackBar(snackBar);
        clearTextInput();
      } 
      break; 
    } 
  });
 }

 _animateButton(){
   double initialWidth = _buttonKey.currentContext.size.width;

   var controller = AnimationController(duration: Duration(milliseconds: 800), vsync: this);

   controller.forward();
  
    setState(() {
      _buttonSaveState = 1;
    });

    Timer(Duration(milliseconds: 2000),() {
      setState(() {
        _buttonSaveState = 0;
        _buttonSaveWith = initialWidth;
        _isButtonDisabled = true;
      });
     });

     Timer(Duration(milliseconds: 1000), () {
       setState(() {
        _animatingReveal = true;
       });
    });
 }

  Widget buildButtonChild(){
    return Text('Guardar', 
              style: TextStyle(
                fontSize: 18, 
                color: Colors.white,
                )
            );  
  }

   double calculateElevation() {
    if (_animatingReveal) {
      return 0.0;
    } else {
      return _isPressed ? 6.0 : 4.0;
    }
  }
  void reset() {
    _buttonSaveWith = double.infinity;
    _animatingReveal = false;
    _buttonSaveWith = 0;
  }

}
