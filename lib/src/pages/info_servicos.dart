import 'dart:convert';
import 'dart:io';
import 'package:edge_alert/edge_alert.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:focus/src/components/mapa_info_serv.dart';
import 'package:focus/src/components/api.info_servico.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Info_Servicos extends StatefulWidget {
  @override
  _Info_ServicosState createState() => _Info_ServicosState();
}

class _Info_ServicosState extends State<Info_Servicos> {
  final _picker = ImagePicker();
  bool isLoading = true;
  bool isForm = true;
  final _formulario = GlobalKey<FormState>();
  TextEditingController obs = new TextEditingController();
  List<Dados_Info_Serv> info = <Dados_Info_Serv>[];
  File _selectedFile;
  final uri = Uri.parse("https://focuseg.com.br/flutter/upload_imagem_obs.php");

  _getInfoServ() {
    API_INFO_SERV.getInfoServ().then((response) {
      setState(() {
        Iterable lista = json.decode(response.body);
        print(lista);
        info = lista.map((model) => Dados_Info_Serv.fromJson(model)).toList();
        isLoading = false;
      });
    });
  }

  getImage(ImageSource source) async {
    this.setState(() {});
    PickedFile image = await _picker.getImage(source: source);
    if (image != null) {
      File cropped = await ImageCropper.cropImage(
          sourcePath: image.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          compressQuality: 80,
          maxWidth: 400,
          maxHeight: 400,
          compressFormat: ImageCompressFormat.jpg,
          androidUiSettings: AndroidUiSettings(
            toolbarColor: Colors.deepOrange,
            toolbarTitle: "Imagem da OBS",
            statusBarColor: Colors.deepOrange.shade900,
            backgroundColor: Colors.white,
          ));

      this.setState(() {
        _selectedFile = File(image.path);
        _selectedFile = cropped;
        if (cropped != null) {
          uploadImage();
        }
      });
    }
  }

  Future uploadImage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String idOs = prefs.getString('idOs');

    var request = http.MultipartRequest('POST', uri);
    request.fields['idOs'] = idOs;
    var pic = await http.MultipartFile.fromPath("image", _selectedFile.path);
    request.files.add(pic);
    var response = await request.send();

    if (response.statusCode == 200) {
      Navigator.of(context).pop();
      EdgeAlert.show(context,
          title: 'Imagem incluída',
          gravity: EdgeAlert.BOTTOM,
          backgroundColor: Colors.green,
          icon: Icons.check);
    } else {
      Navigator.of(context).pop();
      EdgeAlert.show(context,
          title: 'Imagem não Incluída',
          gravity: EdgeAlert.BOTTOM,
          backgroundColor: Colors.red,
          icon: Icons.highlight_off);
    }
    _selectedFile = null;
  }

  Future<List> _enviar() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String idOs = prefs.getString('idOs');

    final response = await http.post(
        Uri.https("www.focuseg.com.br", '/flutter/enviar_obs.php'),
        body: {"obs": obs.text, "idOs": idOs});

    var dados_usuario = json.decode(response.body);

    print(dados_usuario);
    if (dados_usuario == 1) {
      setState(() {
        _getInfoServ();
        isLoading = false;
      });
      EdgeAlert.show(context,
          title: 'Sua Obs Foi Incluída com Sucesso',
          gravity: EdgeAlert.BOTTOM,
          backgroundColor: Colors.green,
          icon: Icons.check);
    } else {
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
      EdgeAlert.show(context,
          title: 'Imagem não Incluída',
          gravity: EdgeAlert.BOTTOM,
          backgroundColor: Colors.red,
          icon: Icons.highlight_off);
    }
  }

  @override
  void initState() {
    super.initState();
    _getInfoServ();
  }

  void _configurandoModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            margin: EdgeInsets.only(bottom: 30),
            child: Wrap(
              children: <Widget>[
                ListTile(
                    title: Center(
                        child: Text(
                  "Incluir Imagem",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                ))),
                Divider(
                  height: 20,
                  color: Colors.blueGrey,
                ),
                ListTile(
                    leading: new Icon(
                      Icons.camera_alt,
                      color: Colors.blueGrey,
                    ),
                    title: new Text('Câmera'),
                    trailing: new Icon(
                      Icons.arrow_right,
                      color: Colors.blueGrey,
                    ),
                    onTap: () => {getImage(ImageSource.camera)}),
                Divider(
                  height: 20,
                  color: Colors.blueGrey,
                ),
                ListTile(
                    leading:
                        new Icon(Icons.collections, color: Colors.blueGrey),
                    title: new Text('Galeria de Fotos'),
                    trailing:
                        new Icon(Icons.arrow_right, color: Colors.blueGrey),
                    onTap: () => {getImage(ImageSource.gallery)}),
                Divider(
                  height: 20,
                  color: Colors.blueGrey,
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
        title: Text('Informação Serviço'),
        centerTitle: true,
        backgroundColor: Colors.red[900],
      ),
      resizeToAvoidBottomInset: true, //use this
      body: SingleChildScrollView(
          child: isLoading
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
              : main()),
    );
  }

  Stack main() {
    return Stack(children: <Widget>[
      Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.black,
            child: ListView.builder(
                itemCount: info.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Padding(
                              padding: EdgeInsets.fromLTRB(10, 30, 0, 0),
                              child: Icon(
                                Icons.business,
                                color: Colors.red[400],
                              )),
                          Padding(
                            padding: EdgeInsets.fromLTRB(20, 30, 0, 0),
                            child: Text(info[index].nome_cliente,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Padding(
                              padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                              child: Icon(
                                Icons.arrow_right,
                                color: Colors.red[400],
                                size: 32,
                              )),
                          Padding(
                            padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                            child: Text('${info[index].checkin}h',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white)),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Padding(
                              padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: Icon(
                                Icons.arrow_left,
                                color: Colors.red[400],
                                size: 32,
                              )),
                          Padding(
                            padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                            child: Text('${info[index].checkout}h',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white)),
                          ),
                        ],
                      ),
                      info[index].obs != ""
                          ? Row(
                              children: [
                                Container(
                                  child: Padding(
                                      padding: EdgeInsets.fromLTRB(14, 0, 0, 0),
                                      child: Icon(
                                        Icons.info_outline,
                                        color: Colors.red[400],
                                        size: 24,
                                      )),
                                ),
                                Container(
                                    child: Padding(
                                  padding: EdgeInsets.fromLTRB(14, 0, 0, 0),
                                  child: Text('${info[index].obs}',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.white)),
                                )),
                              ],
                            )
                          : Container(),
                      info[index].imgserv != ""
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(50, 30, 0, 0),
                              child: Row(
                                children: [
                                  Container(
                                    child: Column(
                                      children: [
                                        Container(
                                            margin: EdgeInsets.fromLTRB(
                                                180, 0, 0, 0),
                                            child: Center(
                                              child: Icon(
                                                Icons.edit,
                                                size: 22,
                                                color: Colors.white,
                                              ),
                                            ),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.red[900],
                                            )),
                                      ],
                                    ),
                                    width: 200,
                                    height: 200,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        image: DecorationImage(
                                          image: NetworkImage(
                                              'https://www.focuseg.com.br/areadm/downloads/fotoservicos/${info[index].imgserv}'),
                                        )),
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                      Form(
                        //autovalidate: true,
                        key: _formulario,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                              child: Container(
                                //color: Color(0xfff5f5f5),
                                child: info[index].obs == ""
                                    ? TextFormField(
                                        controller: obs,
                                        maxLines: 4,
                                        maxLength: 1000,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'SFUIDisplay'),
                                        decoration: InputDecoration(
                                            counterStyle:
                                                TextStyle(color: Colors.white),
                                            border: OutlineInputBorder(),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.red[900],
                                                  width: 3.0),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                borderSide: BorderSide(
                                                    color: Colors.white)),
                                            labelText: 'Entre com a observação',
                                            //prefixIcon:
                                            // Icon(Icons.mail_outline, color: Colors.white),
                                            labelStyle: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16)),
                                      )
                                    : Container(),
                              ),
                            ),
                            info[index].obs == ""
                                ? Padding(
                                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                    child: ButtonTheme(
                                      height: 50.0,
                                      child: TextButton(
                                        onPressed: () {
                                          obs.text == ''
                                              ? Text(
                                                  'Campo Vazio',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                )
                                              : setState(() {
                                                  isLoading = true;
                                                  _enviar();
                                                });
                                        },
                                        child: Text(
                                          "Enviar",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
                                        ),
                                        style: TextButton.styleFrom(
                                          primary: Colors.white,
                                          backgroundColor: Colors.red[900],
                                          onSurface: Colors.white,
                                          shadowColor: Colors.grey[500],
                                          elevation: 5,
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10))),
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(),
                            info[index].imgserv == ''
                                ? Column(
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(10, 50, 10, 0),
                                        child: IconButton(
                                          icon: const Icon(Icons.image_search),
                                          tooltip:
                                              'Mande uma imagem do serviço',
                                          color: Colors.red[400],
                                          iconSize: 60,
                                          onPressed: () {
                                            setState(() {
                                              _configurandoModalBottomSheet(
                                                  context);
                                            });
                                          },
                                        ),
                                      ),
                                      Text('Mande uma Imagem',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white)),
                                    ],
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
          ),
        ],
      ),
    ]);
  }
}
