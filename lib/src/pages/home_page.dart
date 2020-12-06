import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  final formKey = GlobalKey<FormState>();

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
            key: formKey,
            child: ListView(
              children: <Widget>[
                _createBarcode(),
                _createDescription(),
                _createPrice(),
                _createSaveProductButton(context),
                SizedBox(height: MediaQuery.of(context).size.height*0.35),
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
          "7790070412348",
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
        decoration: InputDecoration(
          labelText: "Descripción",
          contentPadding: EdgeInsets.all(10.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0)
          ),
        ),
        onSaved: ( value ) => {},
        validator: ( descriptionValue ){
          return null;
        },
        onChanged: ( descriptionValue ) => setState(() {
  
          })
      ),
    );
  }

    Widget _createPrice() {
    return Container(
        margin: EdgeInsets.only(bottom: 30.0),
        child: TextFormField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "Precio",
            contentPadding: EdgeInsets.all(10.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0)
            ),
          ),
          onSaved: ( value ) => {},
          validator: ( descriptionValue ){
            return null;
          },
          onChanged: ( descriptionValue ) => setState(() {
    
            })
        ),
      );
    }

 Widget _createSaveProductButton(BuildContext context) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0)
        ),
      onPressed: () => {},
      padding: EdgeInsets.all(10.0),
      color: Colors.blue,
        child: Text('Guardar', 
          style: TextStyle(
            fontSize: 18, 
            color: Colors.white,
            )
        )
        );
  }

 Widget _createScanButton(BuildContext context) {
    return RaisedButton.icon(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0)
        ),
      onPressed: () => {},
      padding: EdgeInsets.all(10.0),
      color: Colors.blue,
        icon: Icon(Icons.settings_overscan, color: Colors.white),
        label: Text('Escanear', style: TextStyle(fontSize: 18.0, color: Colors.white),),

        );
  }

}
