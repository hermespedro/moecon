import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json&key=f4933380";
void main() async {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
      theme: ThemeData(
        hintColor: Colors.redAccent[100],
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.redAccent[100])),
          hintStyle: TextStyle(color: Colors.redAccent[100]),
        ),
      ),
    ),
  );
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final usdController = TextEditingController();
  final eurController = TextEditingController();
  final libraController = TextEditingController();

  double dolar;
  double euro;
  double libra;

  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearAll();

      return;
    }
    double real = double.parse(text);
    usdController.text = (real / dolar).toStringAsFixed(2);
    eurController.text = (real / euro).toStringAsFixed(2);
    libraController.text = (real / libra).toStringAsFixed(2);
  }

  void _usdChanged(String text) {
    if (text.isEmpty) {
      _clearAll();

      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    eurController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
    libraController.text = (dolar * this.dolar / libra).toStringAsFixed(2);
  }

  void _eurChanged(String text) {
    if (text.isEmpty) {
      _clearAll();

      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    usdController.text = (euro * this.euro / dolar).toStringAsFixed(2);
    libraController.text = (euro * this.euro / libra).toStringAsFixed(2);
  }

  void _libraChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double libra = double.parse(text);

    realController.text = (libra * this.libra).toStringAsFixed(2);
    usdController.text = (libra * this.libra / dolar).toStringAsFixed(2);
    eurController.text = (libra * this.libra / euro).toStringAsFixed(2);
  }

  void _clearAll() {
    realController.text = "";
    usdController.text = "";
    eurController.text = "";
    libraController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Moecon",
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  "Carregando dados",
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Erro ao carregador dados",
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                libra = snapshot.data["results"]["currencies"]["GBP"]["buy"];

                //style titulo
                var textStyle = TextStyle(
                  color: Colors.redAccent,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w500,
                );

                return SingleChildScrollView(
                  padding: EdgeInsets.all(15.0),
                  child: Column(
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.check,
                            size: 80.0,
                            color: Colors.white30,
                          ),
                          Text(
                            "Conversor de Moedas",
                            style: textStyle,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      Divider(
                        height: 2,
                      ),
                      Text(
                        "Digite o valor a ser convertido",
                        style: TextStyle(color: Colors.white),
                      ),
                      Divider(),
                      buildTextField("R\$", realController, _realChanged),
                      Divider(),
                      buildTextField("USD", usdController, _usdChanged),
                      Divider(),
                      buildTextField("EUR", eurController, _eurChanged),
                      Divider(),
                      buildTextField("GBP", libraController, _libraChanged),
                      Divider(),
                      // RaisedButton(
                      //   onPressed: () {
                      //     print((dolar * 2 + euro * 3).toStringAsFixed(2));
                      //   },
                      //   child: Text(
                      //     "Converter",
                      //     style: TextStyle(
                      //       color: Colors.redAccent[100],
                      //     ),
                      //   ),
                      // )
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Future<Map> getData() async {
  http.Response response = await http.get(request);

  return json.decode(response.body);
}

Widget buildTextField(
    String label, TextEditingController controller, Function onChanged) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.white,
      ),
      border: OutlineInputBorder(),
      prefixText: "R\$",
    ),
    style: TextStyle(
      color: Colors.redAccent[100],
    ),
    onChanged: onChanged,
    keyboardType: TextInputType.number,
  );
}
