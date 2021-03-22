import 'dart:convert';
import 'dart:async';
import 'package:edge_alert/edge_alert.dart';
import 'package:flutter/material.dart';
import 'package:focus/src/components/api_servicos.dart';
import 'package:focus/src/components/mapa_servicos.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

//const url_agendar = "https://focuseg.com.br/flutter/agendar_servicos.php";

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

  void _configurandoModalBottomSheet(
      context,
      String nome_cliente,
      String endereco,
      String tipos,
      String idProf,
      String status,
      String idServ,
      String idos,
      String dt_agenda) {
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
                status == "Finalizada"
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
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 50,
                              child: RaisedButton(
                                onPressed: () async {
                                  final selectedDate =
                                      await _selectDateTime(context);
                                  if (selectedDate == null) return;

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
                                shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(10)),
                                child: Text(
                                  status == "Pendente"
                                      ? "Agendar"
                                      : "Reagendar",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
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
                      ),
              ],
            ),
          );
        });
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

  _ServicosState() {
    _getServicos();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Serviços'),
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
          : _listaServicos(),
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
      return Container(
        color: Colors.black,
        child: ListView.builder(
            itemCount: servicos.length,
            itemBuilder: (context, index) {
              return Card(
                color: servicos[index].status == 'Pendente'
                    ? Colors.yellow
                    : servicos[index].status == 'Agendado'
                        ? Colors.blue[200]
                        : servicos[index].status == 'Em visita'
                            ? Colors.red[100]
                            : servicos[index].status == 'Visitado | Pendente'
                                ? Colors.amber
                                : servicos[index].status ==
                                        'Agendado | Re-visita'
                                    ? Colors.blue
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
                    );
                  },
                  leading:
                      Icon(Icons.notifications_active, color: Colors.red[900]),
                  title: Text(servicos[index].nome_cliente,
                      style: TextStyle(fontSize: 18, color: Colors.black54)),
                  trailing: Text("OS " + servicos[index].idos,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54)),
                  subtitle: Text(
                    servicos[index].data_create,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black26),
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

Future<DateTime> _selectDateTime(BuildContext context) => showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(seconds: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
