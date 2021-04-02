import 'dart:convert';
import 'dart:async';
import 'dart:core';
import 'package:edge_alert/edge_alert.dart';
import 'package:flutter/material.dart';
import 'package:focus/src/components/api_clientes.dart';
import 'package:focus/src/components/mapa_clientes.dart';
import 'package:focus/src/components/utils/box_search.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';

import '../components/mapa_clientes.dart';

class Clientes extends StatefulWidget {
  @override
  _ClientesState createState() => _ClientesState();
}

class _ClientesState extends State<Clientes> {
  //var Clientes = new List<Dados_Clientes>();

  List<Dados_Clientes> clientes = <Dados_Clientes>[];
  bool isLoading = true;
  bool isSearching = false;

  _getClientes() {
    API.getClientes().then((response) {
      setState(() {
        Iterable lista = json.decode(response.body);
        clientes =
            lista.map((model) => Dados_Clientes.fromJson(model)).toList();
        isLoading = false;
      });
    });
  }

  _ClientesState() {
    _getClientes();
  }

  _alertatelvazio() {
    EdgeAlert.show(context,
        title: 'Telefone Vazio!',
        gravity: EdgeAlert.BOTTOM,
        backgroundColor: Colors.red,
        icon: Icons.highlight_off);
  }

  Future<void> _makePhoneCall(String cel) async {
    var celular = cel
        .replaceAll("(", "")
        .replaceAll(")", "")
        .replaceAll("-", "")
        .replaceAll(" ", "");

    var celFinal = "tel:$celular";

    if (await canLaunch(celFinal)) {
      await launch(celFinal);
    } else {
      EdgeAlert.show(context,
          title: 'Erro! Não foi possível ligar para este celular.',
          gravity: EdgeAlert.BOTTOM,
          backgroundColor: Colors.red,
          icon: Icons.highlight_off);
    }
  }

  Future<void> _launchInWebViewWithJavaScript(String cel) async {
    var celular = cel
        .replaceAll("(", "")
        .replaceAll(")", "")
        .replaceAll("-", "")
        .replaceAll(" ", "")
        .replaceAll("+", "");

    //var url = "https://api.whatsapp.com/send?phone=55${celular}_blank";

    FlutterOpenWhatsapp.sendSingleMessage("55$celular", "");

    /*if (await send(celular, 'hello')) {
      
      /*await launch(
        url,
        forceSafariVC: false,
        forceWebView: true,
        enableJavaScript: true,
      );*/

    } else {
      EdgeAlert.show(context,
          title:
              'Erro! Não foi possível enviar mensagem para este celular $cel.',
          gravity: EdgeAlert.BOTTOM,
          backgroundColor: Colors.red,
          icon: Icons.highlight_off);
    }*/
  }

  var search = TextEditingController();
  List<Dados_Clientes> searchResult = <Dados_Clientes>[];

  onSearchTextChanged(String text) {
    searchResult.clear();
    if (text.isEmpty) {
      return;
    }
    clientes.forEach((details) {
      if (details.nome_cliente.toLowerCase().contains(text.toLowerCase()) ||
          details.tipo.toLowerCase().contains(text.toLowerCase()))
        searchResult.add(details);
      setState(() {});
    });
  }

  void _configurandoModalBottomSheet(
      context,
      String nome_cliente,
      String endereco,
      String bairrocidade,
      String tel,
      String cel,
      String latlng,
      String tipo) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            margin: EdgeInsets.all(15),
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: new Icon(
                    Icons.business,
                    color: Colors.red[900],
                    size: 40,
                  ),
                  title: Text(
                    nome_cliente,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  ),
                  subtitle: Text(
                    "$endereco | $bairrocidade\n($tipo)",
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                Divider(
                  height: 20,
                  color: Colors.blueGrey,
                ),
                ListTile(
                  leading: new Icon(
                    Icons.phone,
                    color: Colors.blueGrey,
                  ),
                  title: new Text('Ligar Telefone'),
                  trailing: new Icon(
                    Icons.arrow_right,
                    color: Colors.blueGrey,
                  ),
                  onTap: () => tel == ""
                      ? _alertatelvazio()
                      : setState(() {
                          _makePhoneCall(tel);
                        }),
                ),
                ListTile(
                  leading: new Icon(
                    Icons.phone_iphone,
                    color: Colors.blueGrey,
                  ),
                  title: new Text('Ligar Celular'),
                  trailing: new Icon(
                    Icons.arrow_right,
                    color: Colors.blueGrey,
                  ),
                  onTap: () => cel == ""
                      ? _alertatelvazio()
                      : setState(() {
                          _makePhoneCall(cel);
                        }),
                ),
                ListTile(
                  leading: Icon(
                    FontAwesomeIcons.whatsapp,
                    color: Colors.blueGrey,
                  ),
                  title: new Text('Whatsapp'),
                  trailing: new Icon(
                    Icons.arrow_right,
                    color: Colors.blueGrey,
                  ),
                  onTap: () => cel == ""
                      ? _alertatelvazio()
                      : setState(() {
                          _launchInWebViewWithJavaScript(cel);
                        }),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: RaisedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(10)),
                      child: Text(
                        "Cancelar",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clientes'),
        centerTitle: true,
        backgroundColor: Colors.red[900],
        elevation: 0,
        actions: <Widget>[
          IconButton(
              icon: Icon(FontAwesomeIcons.search),
              onPressed: () {
                setState(() {
                  isSearching = !isSearching;
                });
              }),
        ],
      ),
      body: isLoading
          ? Container(
              height: MediaQuery.of(context).size.height,
              color: Colors.black,
              child: Center(
                child: SizedBox(
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation(Colors.red[900]),
                  ),
                  height: 40,
                  width: 40,
                ),
              ),
            )
          : Column(
              children: [
                isSearching
                    ? boxSearch(context, search, onSearchTextChanged)
                    : Container(),
                Expanded(
                  child: _listaClientes(),
                )
              ],
            ),
    );
  }

  _listaClientes() {
    if (clientes.length == 0) {
      return Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.black12,
            child: Image.asset(
              'images/semregistro.png',
              //fit: BoxFit.fitWidth,
              width: 50,
              height: 50,
            ),
          ),
          Center(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 50),
                    //child: Icon(Icons.block, size: 34, color: Colors.red[900]),
                  ),
                  RichText(
                    text: new TextSpan(
                      style: new TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                      ),
                      children: <TextSpan>[
                        new TextSpan(
                            text: 'Sem registros de ',
                            style: TextStyle(fontSize: 20)),
                        new TextSpan(
                            text: 'Clientes ',
                            style: new TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20)),
                      ],
                    ),
                  )
                ]),
          )
        ],
      );
    } else {
      return searchResult.isNotEmpty || search.value.text.isNotEmpty
          ? Container(
              color: Colors.black,
              child: ListView.builder(
                  itemCount: searchResult.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: Colors.grey[50],
                      margin: EdgeInsets.all(8),
                      child: ListTile(
                        onTap: () {
                          _configurandoModalBottomSheet(
                            context,
                            searchResult[index].nome_cliente,
                            searchResult[index].endereco,
                            searchResult[index].bairrocidade,
                            searchResult[index].tel,
                            searchResult[index].cel,
                            searchResult[index].latlng,
                            searchResult[index].tipo,
                          );
                        },
                        selected: true,
                        leading: Icon(
                          Icons.business,
                          color: Colors.red[900],
                          size: 32,
                        ),
                        title: Text(searchResult[index].nome_cliente,
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                                fontWeight: FontWeight.bold)),
                        trailing:
                            Icon(Icons.arrow_right, color: Colors.red[900]),
                        subtitle: Text(searchResult[index].tipo,
                            style: TextStyle(
                                fontSize: 14,
                                //fontWeight: FontWeight.bold,
                                color: Colors.black)),
                      ),
                    );
                  }),
            )
          : Container(
              color: Colors.black,
              child: ListView.builder(
                  itemCount: clientes.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: Colors.grey[50],
                      margin: EdgeInsets.all(8),
                      child: ListTile(
                        onTap: () {
                          _configurandoModalBottomSheet(
                            context,
                            clientes[index].nome_cliente,
                            clientes[index].endereco,
                            clientes[index].bairrocidade,
                            clientes[index].tel,
                            clientes[index].cel,
                            clientes[index].latlng,
                            clientes[index].tipo,
                          );
                        },
                        selected: true,
                        leading: Icon(
                          Icons.business,
                          color: Colors.red[900],
                          size: 32,
                        ),
                        title: Text(clientes[index].nome_cliente,
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                                fontWeight: FontWeight.bold)),
                        trailing:
                            Icon(Icons.arrow_right, color: Colors.red[900]),
                        subtitle: Text(clientes[index].tipo,
                            style: TextStyle(
                                fontSize: 14,
                                //fontWeight: FontWeight.bold,
                                color: Colors.black)),
                      ),
                    );
                  }),
            );
    }
  }
}
