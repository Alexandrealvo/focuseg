import 'dart:convert';
import 'dart:async';
import 'package:edge_alert/edge_alert.dart';
import 'package:flutter/material.dart';
import 'package:focus/src/components/api_servicos.dart';
import 'package:focus/src/components/mapa_servicos.dart';
import 'package:focus/src/components/utils/box_search.dart';
import 'package:focus/src/pages/calendario.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:focus/src/pages/info_servicos.dart';

import 'home_page.dart';

class Servicos extends StatefulWidget {
  @override
  _ServicosState createState() => _ServicosState();
}

class _ServicosState extends State<Servicos> {
  DateTime selectedDate = DateTime.now();

  final DateFormat dateFormat = DateFormat('dd-MM-yyyy');
  final DateFormat timeFormat = DateFormat('HH:mm');

  //var servicos = new List<Dados_Servicos>();
  List<Dados_Servicos> servicos = <Dados_Servicos>[];
  bool isLoading = true;
  bool isSearching = false;
  var cor_drawer = Colors.yellow[300];

  showAlertDialog(BuildContext context, String data, String time, String idServ,
      String status, String idos) {
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
        "Confirmar",
        style: TextStyle(fontSize: 20, color: Colors.red),
      ),
      onPressed: () {
        _agendar(data, time, idServ, status, idos);
        Navigator.of(context).pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.blueGrey[12],
      title: Text("Confirma Agendamento?"),
      content: Text("Para: $data às ${time}h"),
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

  void _abrir_agenda() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Calendario();
    }));
  }

  void _abrir_page_info(idOs) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('idOs', idOs);

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Info_Servicos();
    }));
  }

  void _configurandoModalBottomSheet(
    context,
    String nome_cliente,
    String endereco,
    String tipos,
    String idProf,
    String status,
    String idServ,
    String idos,
    String dt_agenda,
    String info_checkin,
    String info_checkout,
  ) {
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
                    status,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  ),
                  subtitle: dt_agenda == "00/00/00 00:00"
                      ? Text(tipos)
                      : Text("${dt_agenda}h\n$tipos"),
                ),
                status == "Finalizada" &&
                        (info_checkin != "1" || info_checkout != "1")
                    ? Padding(
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
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            color: Colors.blueGrey,
                          ),
                        ),
                      )
                    : status == "Finalizada" &&
                            (info_checkin == "1" || info_checkout == "1")
                        ? Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 50,
                                  child: RaisedButton(
                                    onPressed: () {
                                      _abrir_page_info(idos);
                                    },
                                    shape: new RoundedRectangleBorder(
                                        borderRadius:
                                            new BorderRadius.circular(10)),
                                    child: Text(
                                      "Info Check",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18),
                                    ),
                                    color: Colors.black,
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
                                        borderRadius:
                                            new BorderRadius.circular(10)),
                                    child: Text(
                                      "Cancelar",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18),
                                    ),
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              )
                            ],
                          )
                        : status == "Aceito Pendente" ||
                                status == "Retorno Pendente"
                            ? Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: 50,
                                      child: TextButton(
                                        onPressed: () async {
                                          final selectedTime =
                                              await _selectTime(context);
                                          if (selectedTime == null) return;

                                          setState(() {
                                            this.selectedDate = DateTime(
                                              selectedDate.year,
                                              selectedDate.month,
                                              selectedDate.day,
                                              selectedTime.hour,
                                              selectedTime.minute,
                                            );

                                            Navigator.of(context).pop();
                                            showAlertDialog(
                                                context,
                                                dateFormat.format(selectedDate),
                                                '${selectedTime.hour}:${selectedTime.minute}',
                                                idServ,
                                                status,
                                                idos);
                                          });
                                        },
                                        child: Text(
                                          "Agendar",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18),
                                        ),
                                        style: TextButton.styleFrom(
                                          primary: Colors.white,
                                          backgroundColor: Colors.green,
                                          onSurface: Colors.black12,
                                          shadowColor: Colors.black,
                                          elevation: 5,
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10))),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: 50,
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          "Cancelar",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18),
                                        ),
                                        style: TextButton.styleFrom(
                                          primary: Colors.white,
                                          backgroundColor: Colors.blueGrey,
                                          onSurface: Colors.black12,
                                          shadowColor: Colors.black,
                                          elevation: 5,
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10))),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              )
                            : Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: 50,
                                      child: TextButton(
                                        onPressed: () async {
                                          final selectedTime =
                                              await _selectTime(context);
                                          if (selectedTime == null) return;

                                          setState(() {
                                            this.selectedDate = DateTime(
                                              selectedDate.year,
                                              selectedDate.month,
                                              selectedDate.day,
                                              selectedTime.hour,
                                              selectedTime.minute,
                                            );

                                            Navigator.of(context).pop();
                                            showAlertDialog(
                                                context,
                                                dateFormat.format(selectedDate),
                                                '${selectedTime.hour}:${selectedTime.minute}',
                                                idServ,
                                                status,
                                                idos);
                                          });
                                        },
                                        child: isLoading
                                            ? SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation(
                                                          Colors.white),
                                                ),
                                              )
                                            : Text(
                                                "Reagendar",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18),
                                              ),
                                        style: TextButton.styleFrom(
                                          primary: Colors.white,
                                          backgroundColor: Colors.green,
                                          onSurface: Colors.black12,
                                          shadowColor: Colors.black,
                                          elevation: 5,
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10))),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: 50,
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          _abrir_agenda();
                                        },
                                        child: isLoading
                                            ? SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation(
                                                          Colors.white),
                                                ),
                                              )
                                            : Text(
                                                "Agenda",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18),
                                              ),
                                        style: TextButton.styleFrom(
                                          primary: Colors.white,
                                          backgroundColor: Colors.red[400],
                                          onSurface: Colors.black12,
                                          shadowColor: Colors.black,
                                          elevation: 5,
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10))),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: 50,
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: isLoading
                                            ? SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation(
                                                          Colors.white),
                                                ),
                                              )
                                            : Text(
                                                "Cancelar",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18),
                                              ),
                                        style: TextButton.styleFrom(
                                          primary: Colors.white,
                                          backgroundColor: Colors.blueGrey,
                                          onSurface: Colors.black12,
                                          shadowColor: Colors.black,
                                          elevation: 5,
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10))),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
              ],
            ),
          );
        });
  }

  Future<List> _agendar(String data, String time, String idServ, String status,
      String idos) async {
    final response = await http.post(
        Uri.https("www.focuseg.com.br", '/flutter/agendar_servicos.php'),
        body: {
          "idServ": idServ,
          "data": data,
          "time": time,
          "status": status,
          "idos": idos
        });

    var dados = json.decode(response.body);

    if (dados['valida'] == 1) {
      setState(() {
        _getServicos();
      });
    } else {
      //Navigator.pushNamed(context, '/servicos');
      EdgeAlert.show(context,
          title: 'Erro! Tente novamente.',
          gravity: EdgeAlert.BOTTOM,
          backgroundColor: Colors.red,
          icon: Icons.highlight_off);
    }
  }

  _getServicos() {
    API_SERV.getServicos().then((response) {
      setState(() {
        Iterable lista = json.decode(response.body);
        servicos =
            lista.map((model) => Dados_Servicos.fromJson(model)).toList();
        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _getServicos();
  }

  var search = TextEditingController();
  List<Dados_Servicos> searchResult = <Dados_Servicos>[];

  onSearchTextChanged(String text) {
    searchResult.clear();
    if (text.isEmpty) {
      return;
    }
    servicos.forEach((details) {
      if (details.nome_cliente.toLowerCase().contains(text.toLowerCase()) ||
          details.idos.toLowerCase().contains(text.toLowerCase()) ||
          details.data_create.toLowerCase().contains(text.toLowerCase()))
        searchResult.add(details);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String nome = prefs.getString('nome');
        final String tipo = prefs.getString('tipo');
        final String imgperfil = prefs.getString('imgperfil');
        final String email = prefs.getString('email');
        final String id = prefs.getString('idusu');

        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) =>
                    HomePage(id, nome, tipo, imgperfil, email)),
            (Route<dynamic> route) => false);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Serviços'),
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
                    child: _listaServicos(),
                  ),
                ],
              ),
      ),
    );
  }

  _listaServicos() {
    if (servicos.length == 0) {
      return Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.black12,
            child: Image.asset(
              'images/semregistro.png',
              fit: BoxFit.fitWidth,
            ),
          ),
          Center(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 100),
                    //child: Icon(Icons.block, size: 34, color: Colors.red[900]),
                  ),
                  RichText(
                    text: new TextSpan(
                      // Note: Styles for TextSpans must be explicitly defined.
                      // Child text spans will inherit styles from parent
                      style: new TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                      ),
                      children: <TextSpan>[
                        new TextSpan(
                            text: 'Sem registros de ',
                            style: TextStyle(fontSize: 20)),
                        new TextSpan(
                            text: 'Serviços',
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
                      color: searchResult[index].status == 'Pendente Aceite'
                          ? Colors.yellow
                          : searchResult[index].status == 'Aceito Pendente'
                              ? Colors.yellow[400]
                              : searchResult[index].status == 'Agendado'
                                  ? Colors.blue[100]
                                  : searchResult[index].status == 'Em visita'
                                      ? Colors.deepOrange[300]
                                      : searchResult[index].status ==
                                              'Visitado | Pendente'
                                          ? Colors.amber
                                          : searchResult[index].status ==
                                                  'Agendado | Re-visita'
                                              ? Colors.blue
                                              : searchResult[index].status ==
                                                          'Finalizada' &&
                                                      (searchResult[index]
                                                                  .info_checkin ==
                                                              "1" ||
                                                          searchResult[index]
                                                                  .info_checkout ==
                                                              "1")
                                                  ? Colors.blueGrey
                                                  : Colors.green,
                      margin: EdgeInsets.all(8),
                      child: ListTile(
                        onTap: () {
                          _configurandoModalBottomSheet(
                            context,
                            searchResult[index].nome_cliente,
                            searchResult[index].endereco,
                            searchResult[index].tipos,
                            searchResult[index].idProf,
                            searchResult[index].status,
                            searchResult[index].idServ,
                            searchResult[index].idos,
                            searchResult[index].dt_agenda,
                            searchResult[index].info_checkin,
                            searchResult[index].info_checkout,
                          );
                        },
                        leading: Icon(Icons.build_circle_outlined,
                            size: 32, color: Colors.red[900]),
                        title: Text(searchResult[index].nome_cliente,
                            style:
                                TextStyle(fontSize: 18, color: Colors.black54)),
                        trailing: Text("OS " + searchResult[index].idos,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54)),
                        subtitle: Text(
                          searchResult[index].data_create,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black26),
                        ),
                      ),
                    );
                  }),
            )
          : Container(
              color: Colors.black,
              child: ListView.builder(
                  itemCount: servicos.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: servicos[index].status == 'Pendente Aceite'
                          ? Colors.yellow
                          : servicos[index].status == 'Aceito Pendente'
                              ? Colors.yellow[400]
                              : servicos[index].status == 'Agendado'
                                  ? Colors.blue[100]
                                  : servicos[index].status == 'Em visita'
                                      ? Colors.deepOrange[300]
                                      : servicos[index].status ==
                                              'Visitado | Pendente'
                                          ? Colors.amber
                                          : servicos[index].status ==
                                                  'Agendado | Re-visita'
                                              ? Colors.blue
                                              : servicos[index].status ==
                                                          'Finalizada' &&
                                                      (servicos[index]
                                                                  .info_checkin ==
                                                              "1" ||
                                                          servicos[index]
                                                                  .info_checkout ==
                                                              "1")
                                                  ? Colors.blueGrey
                                                  : Colors.green,
                      margin: EdgeInsets.all(8),
                      child: ListTile(
                        onTap: () {
                          _configurandoModalBottomSheet(
                            context,
                            servicos[index].nome_cliente,
                            servicos[index].endereco,
                            servicos[index].tipos,
                            servicos[index].idProf,
                            servicos[index].status,
                            servicos[index].idServ,
                            servicos[index].idos,
                            servicos[index].dt_agenda,
                            servicos[index].info_checkin,
                            servicos[index].info_checkout,
                          );
                        },
                        leading: Icon(Icons.build_circle_outlined,
                            size: 32, color: Colors.red[900]),
                        title: Text(servicos[index].nome_cliente,
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w500)),
                        trailing: Text("OS " + servicos[index].idos,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        subtitle: Text(
                          servicos[index].data_create,
                          style: TextStyle(fontSize: 12, color: Colors.black),
                        ),
                      ),
                    );
                  }),
            );
    }
  }
}

Future<TimeOfDay> _selectTime(BuildContext context) {
  final now = DateTime.now();

  return showTimePicker(
    context: context,
    initialTime: TimeOfDay(hour: now.hour, minute: now.minute),
  );
}
