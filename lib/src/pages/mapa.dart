import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:focus/src/components/api_clientes.dart';
import 'package:focus/src/components/mapa_clientes.dart';

class Mapa extends StatefulWidget {
  @override
  MapaState createState() => MapaState();
}

class MapaState extends State<Mapa> {
  Completer<GoogleMapController> _controller = Completer();
  List<Dados_Clientes> clientes = <Dados_Clientes>[];
  bool isLoading = true;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getClientes();
    clientesNum();
  }

  _getClientes() {
    API.getClientes().then((response) {
      setState(() {
        Iterable lista = json.decode(response.body);
        clientes =
            lista.map((model) => Dados_Clientes.fromJson(model)).toList();
        for (var i = 0; i < clientes.length; i++) {
          _markers.add(Marker(
              markerId: MarkerId(clientes[i].nome_cliente),
              position: LatLng(
                  double.parse(clientes[i].lat), double.parse(clientes[i].lng)),
              infoWindow: InfoWindow(
                title: clientes[i].nome_cliente,
                snippet: clientes[i].endereco,
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueViolet,
              )));
        }
        isLoading = false;
      });
    });
  }

  clientesNum() {}

  double zoomVal = 5.0;
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
                _buildContainer(),
              ],
            ),
    );
  }

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

  Widget _buildContainer() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20.0),
        height: 150.0,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: clientes.length,
          itemBuilder: (context, i) {
            return Row(
              children: [
                SizedBox(width: 10.0),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _boxes(
                    double.parse(clientes[i].lat),
                    double.parse(clientes[i].lng),
                    clientes[i].nome_cliente,
                    clientes[i].endereco,
                    clientes[i].bairrocidade,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _boxes(
      double lat, double long, String nome, String end, String bairro) {
    return GestureDetector(
      onTap: () {
        _gotoLocation(lat, long);
      },
      child: Container(
        child: new FittedBox(
          child: Material(
              color: Colors.red[900],
              elevation: 14.0,
              borderRadius: BorderRadius.circular(24.0),
              shadowColor: Color(0x802196F3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: myDetailsContainer1(nome, end, bairro),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }

  Widget myDetailsContainer1(String nome, end, bairro) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Container(
              child: Text(
            nome,
            style: TextStyle(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.bold),
          )),
        ),
        SizedBox(height: 5.0),
        Container(
            child: Text(
          end,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        )),
        SizedBox(height: 5.0),
        Container(
            child: Text(
          bairro,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.0,
          ),
        )),
      ],
    );
  }

  Widget _buildGoogleMap(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: GoogleMap(
          mapType: MapType.normal,
          zoomControlsEnabled: false,
          zoomGesturesEnabled: true,
          scrollGesturesEnabled: true,
          compassEnabled: true,
          rotateGesturesEnabled: true,
          mapToolbarEnabled: true,
          tiltGesturesEnabled: true,
          initialCameraPosition:
              CameraPosition(target: LatLng(-1.4241198, -48.4647034), zoom: 12),
          onMapCreated: (GoogleMapController controller) {
            if (!_controller.isCompleted) {
              //first calling is false
              //call "completer()"
              _controller.complete(controller);
            } else {
              //other calling, later is true,
              //don't call again complet
            }
            changeMapMode();
            //_controller.complete(controller);
          },
          markers: _markers,
        ));
  }

  Future<void> _gotoLocation(double lat, double long) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, long),
      zoom: 16,
      tilt: 50.0,
      bearing: 45.0,
    )));
  }
}
