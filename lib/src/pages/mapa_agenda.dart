import 'dart:async';
import 'dart:convert';
import 'package:edge_alert/edge_alert.dart';
import 'package:flutter/material.dart';
import 'package:focus/src/components/api.mapa_agenda.dart';
import 'package:focus/src/components/mapa_mapagenda.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;

const url_check = "https://focuseg.com.br/flutter/check.php";

class MapaAgenda extends StatefulWidget {
  //String idOs;
  //MapaAgenda({this.idOs});

  @override
  MapaAgendaState createState() => MapaAgendaState();
}

class MapaAgendaState extends State<MapaAgenda> {
  Completer<GoogleMapController> _controller = Completer();

  List mapa_agenda = new List<DadosAgenda>();
  bool isLoading = true;
  final mapa_array = [];
  String nomecliente;
  String endereco;
  Position currentPosition;
  var geolocator = Geolocator();
  Set<Marker> _markers = {};
  double zoomVal = 12;
  Color cor = Colors.yellow.withOpacity(0.3);

  Set<Circle> circles = Set.from([
    Circle(
      circleId: CircleId('circle'),
      center: LatLng(-1.4241198, -48.4668921),
      radius: 80,
    )
  ]);

  changeMapMode() {
    getJsonFile("images/mapa.json").then(setMapStyle);
  }

  Future<String> getJsonFile(String path) async {
    return await rootBundle.loadString(path);
  }

  void setMapStyle(String mapStyle) async {
    final GoogleMapController controller = await _controller.future;
    controller.setMapStyle(mapStyle);
  }

  _getMapaAgenda() {
    API_MAPA_AGENDA.getMapaAgenda().then((response) {
      setState(() {
        Iterable lista = json.decode(response.body);

        mapa_agenda =
            lista.map((model) => DadosAgenda.fromJson(model)).toList();
        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _getMapaAgenda();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mapa"),
        centerTitle: true,
        backgroundColor: Colors.red[900],
        /* actions: <Widget>[
          IconButton(
              icon: Icon(FontAwesomeIcons.search),
              onPressed: () {
                print('procurar');
              }),
        ],*/
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
          : Stack(
              children: <Widget>[
                _buildGoogleMap(context),
                _floatButtomMapa(),
                // _buildContainer(),
              ],
            ),
    );
  }

  Widget _floatButtomMapa() {
    return Positioned(
      bottom: 80,
      right: 30,
      child: FloatingActionButton(
        elevation: 10,
        onPressed: _atuaLocal,
        child: Icon(Icons.add, semanticLabel: 'Action'),
        backgroundColor: Colors.red[900],
        heroTag: 'call',
        shape: CircleBorder(
          side: BorderSide(
            color: Colors.white,
            width: 4.0,
          ),
        ),
        tooltip: 'Call',
      ),
    );
  }

  void _timer() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;
    LatLng latLatAtual = LatLng(position.latitude, position.longitude);

    Future.delayed(Duration(seconds: 2)).then((_) {
      setState(() {
        _markers.add(Marker(
            markerId: MarkerId('Estou Aqui!'),
            position: latLatAtual,
            infoWindow: InfoWindow(
              title: 'Minha Localização',
              snippet: "$latLatAtual",
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            )));

        // Anything else you want
      });
      _timer();
    });
  }

  Future<List> _check(String lat, String lng, String idOs, String ctlcheckin,
      String latcliente, String lngcliente) async {
    print("lat=$lat lng=$lng idOs=$idOs");
    final response = await http.post(url_check, body: {
      "lat": lat,
      "lng": lng,
      "idOs": idOs,
      "ctlcheckin": ctlcheckin,
      "latcliente": latcliente,
      "lngcliente": lngcliente
    });

    var dados = json.decode(response.body);

    print("valida=> ${dados['valida']}");

    if (dados['valida'] == 1 && ctlcheckin != "1") {
      EdgeAlert.show(context,
          title: 'Check-in Realizado com Sucesso!',
          gravity: EdgeAlert.BOTTOM,
          backgroundColor: Colors.red,
          icon: Icons.check);
      setState(() {
        cor = Colors.red[900].withOpacity(0.3);
        _getMapaAgenda();
      });
    } else if (dados['valida'] == 1 && ctlcheckin == "1") {
      EdgeAlert.show(context,
          title: 'Check-out Realizado com Sucesso!',
          gravity: EdgeAlert.BOTTOM,
          backgroundColor: Colors.green,
          icon: Icons.check);
      setState(() {
        cor = Colors.green.withOpacity(0.3);
        _getMapaAgenda();
      });
    } else if (dados['valida'] == 2) {
      //Navigator.pushNamed(context, '/servicos');
      EdgeAlert.show(context,
          title: 'Erro! Tente Novamente.',
          gravity: EdgeAlert.BOTTOM,
          backgroundColor: Colors.red,
          icon: Icons.highlight_off);
    } else {
      EdgeAlert.show(context,
          title: 'Fora do raio de alcance!.',
          gravity: EdgeAlert.BOTTOM,
          backgroundColor: Colors.red,
          icon: Icons.highlight_off);
    }
  }

  void _pendente(String idOS) {
    print('teste de pendencia idos=$idOS');
  }

  void _configurandoModalBottomSheet(context, LatLng latlng) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            height: MediaQuery.of(context).size.height / 2.5,
            child: ListView.builder(
                itemCount: mapa_agenda.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.all(15),
                    child: mapa_agenda[index].ctlcheckin == "1" &&
                            mapa_agenda[index].ctlcheckout == "1"
                        ? Wrap(
                            children: <Widget>[
                              ListTile(
                                leading: new Icon(
                                  Icons.room,
                                  color: Colors.red[900],
                                  size: 40,
                                ),
                                title: Text(
                                  mapa_agenda[index].cliente,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18),
                                ),
                                subtitle: Text(mapa_agenda[index].endereco),
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
                                        "Observação",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
                                      ),
                                      color: Colors.blue[400],
                                    )),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 50,
                                  child: RaisedButton(
                                    onPressed: () {
                                      _pendente(mapa_agenda[index].idos);
                                      Navigator.of(context).pop();
                                    },
                                    shape: new RoundedRectangleBorder(
                                        borderRadius:
                                            new BorderRadius.circular(10)),
                                    child: Text(
                                      "Alterar Pendente",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18),
                                    ),
                                    color: Colors.amber,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Wrap(
                            children: <Widget>[
                              ListTile(
                                leading: new Icon(
                                  Icons.room,
                                  color: Colors.red[900],
                                  size: 40,
                                ),
                                title: Text(
                                  mapa_agenda[index].cliente,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18),
                                ),
                                subtitle: Text(mapa_agenda[index].endereco),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 50,
                                    child: mapa_agenda[index].ctlcheckin == "1"
                                        ? RaisedButton(
                                            onPressed: () {
                                              _check(
                                                  latlng.latitude.toString(),
                                                  latlng.longitude.toString(),
                                                  mapa_agenda[index].idos,
                                                  mapa_agenda[index].ctlcheckin,
                                                  mapa_agenda[index].lat,
                                                  mapa_agenda[index].lng);
                                              Navigator.of(context).pop();
                                            },
                                            shape: new RoundedRectangleBorder(
                                                borderRadius:
                                                    new BorderRadius.circular(
                                                        10)),
                                            child: Text(
                                              "Check-out",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18),
                                            ),
                                            color: Colors.red[400],
                                          )
                                        : RaisedButton(
                                            onPressed: () {
                                              _check(
                                                  latlng.latitude.toString(),
                                                  latlng.longitude.toString(),
                                                  mapa_agenda[index].idos,
                                                  mapa_agenda[index].ctlcheckin,
                                                  mapa_agenda[index].lat,
                                                  mapa_agenda[index].lng);
                                              Navigator.of(context).pop();
                                            },
                                            shape: new RoundedRectangleBorder(
                                                borderRadius:
                                                    new BorderRadius.circular(
                                                        10)),
                                            child: Text(
                                              "Check-in",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18),
                                            ),
                                            color: Colors.blueAccent,
                                          )),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 50,
                                  child: RaisedButton(
                                    onPressed: () {},
                                    shape: new RoundedRectangleBorder(
                                        borderRadius:
                                            new BorderRadius.circular(10)),
                                    child: Text(
                                      "Atualizar Local",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18),
                                    ),
                                    color: Colors.purple[300],
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
                                      "Voltar",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18),
                                    ),
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  );
                }),
          );
        });
  }

  void _atuaLocal() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;
    LatLng latLatAtual = LatLng(position.latitude, position.longitude);

    _configurandoModalBottomSheet(context, latLatAtual);
  }

  Widget _buildGoogleMap(BuildContext context) {
    return ListView.builder(
        itemCount: mapa_agenda.length,
        itemBuilder: (context, index) {
          return Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: GoogleMap(
                // config do mapa
                mapType: MapType.normal,
                zoomControlsEnabled: false,
                zoomGesturesEnabled: true,
                scrollGesturesEnabled: true,
                compassEnabled: true,
                rotateGesturesEnabled: true,
                mapToolbarEnabled: true,
                tiltGesturesEnabled: true,

                // config para zoom do mapa
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                  new Factory<OneSequenceGestureRecognizer>(
                    () => new EagerGestureRecognizer(),
                  ),
                ].toSet(),
                initialCameraPosition: CameraPosition(
                    target: LatLng(double.parse(mapa_agenda[index].lat),
                        double.parse(mapa_agenda[index].lng)),
                    zoom: 17),
                onMapCreated: (GoogleMapController controller) async {
                  _controller.complete(controller);
                  changeMapMode();

                  //reposicionamento do local do usuário
                  Position position = await Geolocator.getCurrentPosition(
                      desiredAccuracy: LocationAccuracy.high);
                  currentPosition = position;

                  LatLng latLatPosition =
                      LatLng(position.latitude, position.longitude);

                  LatLng latLatCliente = LatLng(
                      double.parse(mapa_agenda[index].lat),
                      double.parse(mapa_agenda[index].lng));

                  //condição para o reposicionamemto
                  if (latLatPosition.latitude <= latLatCliente.latitude) {
                    LatLngBounds bounds = LatLngBounds(
                      southwest: latLatPosition,
                      northeast: latLatCliente,
                    );
                    controller.animateCamera(
                        CameraUpdate.newLatLngBounds(bounds, 50));
                  } else {
                    LatLngBounds bounds = LatLngBounds(
                      southwest: latLatCliente,
                      northeast: latLatPosition,
                    );
                    controller.animateCamera(
                        CameraUpdate.newLatLngBounds(bounds, 50));
                  }
                  //chama a atualização recorrente
                  _timer();

                  // insere os markers
                  setState(() {
                    mapa_agenda[index].ctlcheckin == "0"
                        ? cor = Colors.yellow.withOpacity(0.3)
                        : (mapa_agenda[index].ctlcheckin == "1" &&
                                mapa_agenda[index].ctlcheckout == "0")
                            ? cor = Colors.red[900].withOpacity(0.3)
                            : cor = Colors.green.withOpacity(0.3);

                    _markers.add(Marker(
                        markerId: MarkerId(mapa_agenda[index].cliente),
                        position: LatLng(double.parse(mapa_agenda[index].lat),
                            double.parse(mapa_agenda[index].lng)),
                        infoWindow: InfoWindow(
                          title: mapa_agenda[index].cliente,
                          snippet: mapa_agenda[index].endereco,
                        ),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueViolet,
                        )));
                    _markers.add(Marker(
                        markerId: MarkerId('Estou Aqui!'),
                        position: latLatPosition,
                        infoWindow: InfoWindow(
                          title: 'Minha Localização',
                          snippet: "",
                        ),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed,
                        )));
                  });
                },
                circles: Set.from([
                  Circle(
                    circleId: CircleId('circle'),
                    center: LatLng(double.parse(mapa_agenda[index].lat),
                        double.parse(mapa_agenda[index].lng)),
                    radius: 80,
                    strokeColor: cor,
                    fillColor: cor,
                  )
                ]),
                markers: _markers,
              ));
        });
  }
}
