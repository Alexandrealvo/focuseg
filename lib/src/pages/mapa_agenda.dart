import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:focus/src/components/api.mapa_agenda.dart';
import 'package:focus/src/components/mapa_mapagenda.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

const api = 'https://focuseg.com.br/flutter/mapa_agenda_json.php?idOs=993';

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

  Future<List> getData() async {
    http.Response response = await http.get(api);
    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();
    _getMapaAgenda();
  }

  double zoomVal = 10.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mapa"),
        centerTitle: true,
        backgroundColor: Colors.red[900],
        actions: <Widget>[
          IconButton(
              icon: Icon(FontAwesomeIcons.search),
              onPressed: () {
                print('procurar');
              }),
        ],
      ),
      body: Stack(
        children: <Widget>[
          _buildGoogleMap(context),
          _zoomminusfunction(),
          _zoomplusfunction(),
          _buildContainer(),
        ],
      ),
    );
  }

  Widget _zoomminusfunction() {
    return Align(
      alignment: Alignment.topLeft,
      child: IconButton(
          icon: Icon(FontAwesomeIcons.searchMinus, color: Colors.red[900]),
          onPressed: () {
            zoomVal--;
            _minus(zoomVal);
          }),
    );
  }

  Widget _zoomplusfunction() {
    return Align(
      alignment: Alignment.topRight,
      child: IconButton(
          icon: Icon(FontAwesomeIcons.searchPlus, color: Colors.red[900]),
          onPressed: () {
            zoomVal++;
            _plus(zoomVal);
          }),
    );
  }

  Future<void> _minus(double zoomVal) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(-1.4241198, -48.4668921), zoom: zoomVal)));
  }

  Future<void> _plus(double zoomVal) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(-1.4241198, -48.4668921), zoom: zoomVal)));
  }

  Widget _buildContainer() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 30),
        height: 150,
        width: MediaQuery.of(context).size.width * .60,
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
                itemCount: mapa_agenda.length,
                itemBuilder: (context, index) {
                  return _boxes(
                      double.parse(mapa_agenda[index].lat),
                      double.parse(mapa_agenda[index].lng),
                      mapa_agenda[index].cliente);
                })),
      ),
    );
  }

  Widget _boxes(double lat, double long, String cliente) {
    return GestureDetector(
      onTap: () {
        _gotoLocation(lat, long);
      },
      child: Container(
        child: new FittedBox(
          child: Material(
              color: Colors.white,
              elevation: 15.0,
              borderRadius: BorderRadius.circular(10.0),
              shadowColor: Color(0x802196F3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  /* Container(
                    width: 180,
                    height: 200,
                    child: ClipRRect(
                      borderRadius: new BorderRadius.circular(24.0),
                      child: Image(
                        fit: BoxFit.fill,
                        image: NetworkImage(_image),
                      ),
                    ),
                  ),*/
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: myDetailsContainer1(cliente),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }

  Widget myDetailsContainer1(String cliente) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Container(
              child: Text(
            cliente,
            style: TextStyle(
                color: Colors.red[900],
                fontSize: 24.0,
                fontWeight: FontWeight.bold),
          )),
        ),
        SizedBox(height: 5.0),
      ],
    );
  }

  Widget _buildGoogleMap(BuildContext context) {
    return ListView.builder(
        itemCount: mapa_agenda.length,
        itemBuilder: (context, index) {
          return Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                      target: LatLng(-1.4241198, -48.4647034), zoom: 11),
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  myLocationButtonEnabled: true,
                  // colocar as devidas variavel
                  markers: {
                    Marker(
                        markerId: MarkerId('greenVille'),
                        position: LatLng(double.parse(mapa_agenda[index].lat),
                            double.parse(mapa_agenda[index].lng)),
                        infoWindow:
                            InfoWindow(title: mapa_agenda[index].cliente),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed,
                        ))
                  }));
        });
  }

  Future<void> _gotoLocation(double lat, double long) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, long),
      zoom: 17,
      tilt: 50.0,
      bearing: 45.0,
    )));
  }
}

/*Marker makerCliente = Marker(
  markerId: MarkerId('greenVille'),
  position: LatLng(-1.350564, -48.452712),
  infoWindow: InfoWindow(title: 'nome_cliente'),
  icon: BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueRed,
  ),
);*/
