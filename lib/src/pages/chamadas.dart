import 'dart:convert';
import 'package:edge_alert/edge_alert.dart';
import 'package:flutter/material.dart';
import 'package:focus/src/components/api_chamadas.dart';
import 'package:focus/src/components/mapa_chamadas.dart';
import 'package:http/http.dart' as http;

//const url_aceite = "https://focuseg.com.br/flutter/aceite_chamada.php";

class Chamadas extends StatefulWidget {
  @override
  _ChamadasState createState() => _ChamadasState();
}

class _ChamadasState extends State<Chamadas> {
  var chamadas = new List<Dados_Chamadas>();
  bool isLoading = true;

  _getChamadas() {
    API.getChamadas().then((response) {
      setState(() {
        Iterable lista = json.decode(response.body);
        chamadas =
            lista.map((model) => Dados_Chamadas.fromJson(model)).toList();
        isLoading = false;
      });
    });
  }

  _ChamadasState() {
    _getChamadas();
  }

  showAlertDialog(BuildContext context, String idProf) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text(
        "Cancelar",
        style: TextStyle(fontSize: 20),
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text(
        "Continuar",
        style: TextStyle(fontSize: 20, color: Colors.red),
      ),
      onPressed: () {
        _escolha(idProf, '3');
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.blueGrey[12],
      title: Text("Deseja Recusar Chamada?"),
      content: Text("Alertamos que este procedimento será definitivo."),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _configurandoModalBottomSheet(context, String nome_cliente,
      String endereco, String tipos, String idProf) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            margin: EdgeInsets.all(15),
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: new Icon(
                    Icons.room,
                    color: Colors.red[900],
                    size: 40,
                  ),
                  title: Text(
                    nome_cliente,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  ),
                  subtitle: Text(endereco),
                ),
                ListTile(
                  leading: new Icon(
                    Icons.build,
                    color: Colors.red[900],
                    size: 30,
                  ),
                  title: Text(
                    'Serviço(s)',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  ),
                  subtitle: Text(tipos),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: RaisedButton(
                      onPressed: () {
                        _escolha(idProf, '2');
                      },
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(10)),
                      child: Text(
                        "Aceitar",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      color: Colors.green,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: RaisedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        showAlertDialog(context, idProf);
                      },
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(10)),
                      child: Text(
                        "Recusar",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      color: Colors.red,
                    ),
                  ),
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

  Future<List> _escolha(String id, String ctl) async {
    final response = await http.post(
        Uri.https("www.focuseg.com.br", '/flutter/aceite_chamada.php'),
        body: {
          "idProf": id,
          "ctl": ctl,
        });

    var dados = json.decode(response.body);

    if (dados['valida'] == 1) {
      Navigator.of(context).pop();
      setState(() {
        _getChamadas();
      });
      if (ctl == '2') {
        Navigator.pushNamed(context, '/servicos');
      } else {
        Navigator.of(context).pop();
      }
    } else {
      Navigator.of(context).pop();
      EdgeAlert.show(context,
          title: 'Erro! Tente novamente.',
          gravity: EdgeAlert.BOTTOM,
          backgroundColor: Colors.red,
          icon: Icons.highlight_off);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chamadas'),
        centerTitle: true,
        backgroundColor: Colors.red[900],
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
          : _listaChamadas(),
    );
  }

  _listaChamadas() {
    if (chamadas.length == 0) {
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
                            text: 'Chamadas ',
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
      return Container(
        color: Colors.black,
        child: ListView.builder(
            itemCount: chamadas.length,
            itemBuilder: (context, index) {
              return Card(
                color: Colors.grey[50],
                margin: EdgeInsets.all(8),
                child: ListTile(
                  onTap: () {
                    _configurandoModalBottomSheet(
                        context,
                        chamadas[index].nome_cliente,
                        chamadas[index].endereco,
                        chamadas[index].tipos,
                        chamadas[index].idProf);
                  },
                  selected: true,
                  leading:
                      Icon(Icons.notifications_active, color: Colors.red[900]),
                  title: Text(chamadas[index].nome_cliente,
                      style: TextStyle(fontSize: 18, color: Colors.black54)),
                  trailing: Text("OS " + chamadas[index].idos,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54)),
                  subtitle: Text(chamadas[index].data_create,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black26)),
                ),
              );
            }),
      );
    }
  }
}
