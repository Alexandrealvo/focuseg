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
    return ListView.builder(
      itemCount: clientes.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, i) {
        return Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 20.0),
            height: 150.0,
            child: Row(
              children: [
                SizedBox(width: 10.0),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _boxes(
                      "https://focuseg.com.br/areadm/downloads/fotosclientes/${clientes[i].nome_cliente}.png",
                      -1.350564,
                      -48.452712,
                      clientes[i].nome_cliente),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _boxes(String _image, double lat, double long, String restaurantName) {
    return GestureDetector(
      onTap: () {
        _gotoLocation(lat, long);
      },
      child: Container(
        child: new FittedBox(
          child: Material(
              color: Colors.white,
              elevation: 14.0,
              borderRadius: BorderRadius.circular(24.0),
              shadowColor: Color(0x802196F3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(width: 180, height: 200, child: Container()
                      // ClipRRect(
                      //   borderRadius: new BorderRadius.circular(24.0),
                      //   child: Image(
                      //     fit: BoxFit.fill,
                      //     image: NetworkImage(_image),
                      //   ),
                      // ),
                      ),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: myDetailsContainer1(restaurantName),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }

  Widget myDetailsContainer1(String restaurantName) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Container(
              child: Text(
            restaurantName,
            style: TextStyle(
                color: Colors.red[900],
                fontSize: 24.0,
                fontWeight: FontWeight.bold),
          )),
        ),
        SizedBox(height: 5.0),
        /*Container(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
              child: Icon(
                FontAwesomeIcons.solidStar,
                color: Colors.amber,
                size: 15.0,
              ),
            ),
            Container(
              child: Icon(
                FontAwesomeIcons.solidStar,
                color: Colors.amber,
                size: 15.0,
              ),
            ),
            Container(
              child: Icon(
                FontAwesomeIcons.solidStar,
                color: Colors.amber,
                size: 15.0,
              ),
            ),
            Container(
              child: Icon(
                FontAwesomeIcons.solidStar,
                color: Colors.amber,
                size: 15.0,
              ),
            ),
            Container(
              child: Icon(
                FontAwesomeIcons.solidStarHalf,
                color: Colors.amber,
                size: 15.0,
              ),
            ),
            Container(
                child: Text(
              "(946)",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 18.0,
              ),
            )),
          ],
        )),
        SizedBox(height: 5.0),
        Container(
            child: Text(
          "American \u00B7 \u0024\u0024 \u00B7 1.6 mi",
          style: TextStyle(
            color: Colors.black54,
            fontSize: 18.0,
          ),
        )),
        SizedBox(height: 5.0),
        Container(
            child: Text(
          "Closed \u00B7 Opens 17:00 Thu",
          style: TextStyle(
              color: Colors.black54,
              fontSize: 18.0,
              fontWeight: FontWeight.bold),
        )),*/
      ],
    );
  }

  Widget _buildGoogleMap(BuildContext context) {
    return ListView.builder(
        itemCount: clientes.length,
        itemBuilder: (context, index) {
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
                initialCameraPosition: CameraPosition(
                    target: LatLng(-1.4241198, -48.4647034), zoom: 12),
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
        });
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
