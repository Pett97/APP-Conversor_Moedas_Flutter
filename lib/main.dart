import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

// Constantes devem ser declaradas após os imports
const request = "https://api.hgbrasil.com/finance?key=61601372";

void main() async {
  runApp(MaterialApp(
    home: const Home(),
    theme: ThemeData(hintColor: Colors.amber, primaryColor: Colors.white),
  ));
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dollarController = TextEditingController();
  final euroController = TextEditingController();
  final dollarCanadenseController = TextEditingController();

  late double dolar;
  late double euro;
  late double dolarCanadense;

  void _clearAll() {
    realController.clear();
    dollarController.clear();
    euroController.clear();
    dollarCanadenseController.clear();
  }

  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);

    dollarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
    dollarCanadenseController.text = (real / dolarCanadense).toStringAsFixed(2);
  }

  void _dollarChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double dollar = double.parse(text);
    realController.text = (dollar * dolar).toStringAsFixed(2);
    euroController.text = (dollar * dolar / euro).toStringAsFixed(2);
    dollarCanadenseController.text =
        (dollar * dolar / dolarCanadense).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double euros = double.parse(text);
    realController.text = (euros * euro).toStringAsFixed(2);
    dollarController.text = (euros * euro / dolar).toStringAsFixed(2);
    dollarCanadenseController.text =
        (euros * euro / dolarCanadense).toStringAsFixed(2);
  }

  void _dollarCanadenseChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double cad = double.parse(text);
    realController.text = (cad * dolarCanadense).toStringAsFixed(2);
    dollarController.text = (cad * dolarCanadense / dolar).toStringAsFixed(2);
    euroController.text = (cad * dolarCanadense / euro).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text("Conversor Simples",
              style: TextStyle(color: Colors.amber[500])),
          centerTitle: true,
        ),
        body: FutureBuilder<Map>(
            future: getData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return const Center(
                      child: Text(
                    "Carregando Dados",
                    style: TextStyle(color: Colors.amber, fontSize: 25),
                    textAlign: TextAlign.center,
                  ));
                default:
                  if (snapshot.hasError) {
                    return const Center(
                        child: Text(
                      "Erro Ao Carregar Dados",
                      style: TextStyle(color: Colors.amber, fontSize: 25),
                      textAlign: TextAlign.center,
                    ));
                  } else {
                    dolar = snapshot.data?["USD"]["buy"];
                    euro = snapshot.data?["EUR"]["buy"];
                    dolarCanadense = snapshot.data?["CAD"]["buy"];
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const Icon(
                            Icons.monetization_on,
                            size: 150,
                            color: Colors.amber,
                          ),
                          buildTextField(
                              "Reais", "R\$", realController, _realChanged),
                          const Divider(),
                          buildTextField("Dollar", "R\$", dollarController,
                              _dollarChanged),
                          const Divider(),
                          buildTextField(
                              "Euro", "R€", euroController, _euroChanged),
                          const Divider(),
                          buildTextField(
                              "Dollar Canadense ",
                              "RC\$",
                              dollarCanadenseController,
                              _dollarCanadenseChanged),
                        ],
                      ),
                    );
                  }
              }
            }));
  }
}

Future<Map> getData() async {
  http.Response response = await http.get(Uri.parse(request));
  return json.decode(response.body)["results"]["currencies"];
}

Widget buildTextField(String label, String prefix,
    TextEditingController controller, Function(String) function) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.amber, fontSize: 25),
        border: const OutlineInputBorder(),
        prefixText: prefix),
    style: const TextStyle(color: Colors.amber),
    onChanged: function,
    keyboardType: TextInputType.number,
  );
}
