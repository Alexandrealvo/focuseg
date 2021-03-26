import 'package:flutter/material.dart';
import 'package:focus/src/components/home_widget_bottomtab.dart';
import 'package:focus/src/components/senha.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../login.dart';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:edge_alert/edge_alert.dart';

class HomePage extends StatefulWidget {
  String id;
  String nome_prof;
  String tipo;
  String imgperfil;
  String email_banco;

  HomePage(
      this.id, this.nome_prof, this.tipo, this.imgperfil, this.email_banco);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  final _picker = ImagePicker();
  static List<Widget> bottomNavigationList = <Widget>[
    HomeBottomTab(),
    Senha(),
    Login()
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  File _selectedFile;

  final uri = Uri.parse("https://focuseg.com.br/flutter/upload_imagem.php");

  Future<void> logoutUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs?.clear();
    Navigator.pushNamed(context, '/login');
  }

  Future uploadImage() async {
    var request = http.MultipartRequest('POST', uri);
    request.fields['idusu'] = widget.id;
    var pic = await http.MultipartFile.fromPath("image", _selectedFile.path);
    request.files.add(pic);
    var response = await request.send();

    if (response.statusCode == 200) {
      Navigator.of(context).pop();
      EdgeAlert.show(context,
          title: 'Imagem Alterada',
          gravity: EdgeAlert.BOTTOM,
          backgroundColor: Colors.green,
          icon: Icons.check);
    } else {
      Navigator.of(context).pop();
      EdgeAlert.show(context,
          title: 'Imagem não Enviada',
          gravity: EdgeAlert.BOTTOM,
          backgroundColor: Colors.red,
          icon: Icons.highlight_off);
    }
    _selectedFile = null;
  }

  Widget getImageWidget() {
    if (_selectedFile != null) {
      return GestureDetector(
        onTap: () {
          _configurandoModalBottomSheet(context);
          //Navigator.pushNamed(context, '/Home');
        },
        child: Container(
          child: Column(
            children: [
              Container(
                  margin: EdgeInsets.only(left: 40),
                  child: Center(
                    child: Icon(
                      Icons.edit,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red[900],
                  )),
            ],
          ),
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: new DecorationImage(
              image: new FileImage(_selectedFile),
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          _configurandoModalBottomSheet(context);
          //Navigator.pushNamed(context, '/Home');
        },
        child: Container(
          child: Column(
            children: [
              Container(
                  margin: EdgeInsets.only(left: 40),
                  child: Center(
                    child: Icon(
                      Icons.edit,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red[900],
                  )),
            ],
          ),
          width: 70,
          height: 70,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(
                    'https://www.focuseg.com.br/areadm/downloads/fotosprofissionais/${widget.imgperfil}'),
              )),
        ),
      );
    }
  }

  getImage(ImageSource source) async {
    this.setState(() {});
    PickedFile image = await _picker.getImage(source: source);
    if (image != null) {
      File cropped = await ImageCropper.cropImage(
          sourcePath: image.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          compressQuality: 50,
          maxWidth: 200,
          maxHeight: 200,
          compressFormat: ImageCompressFormat.jpg,
          androidUiSettings: AndroidUiSettings(
            toolbarColor: Colors.deepOrange,
            toolbarTitle: "Imagem para o Perfil",
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

  Future<void> _launchInWebViewWithJavaScript() async {
    const url = "https://api.whatsapp.com/send?phone=5591981220670_blank";
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: true,
        enableJavaScript: true,
      );
    } else {
      EdgeAlert.show(context,
          title: 'Erro! Não foi possível mandar mensagem via Whatsapp.',
          gravity: EdgeAlert.BOTTOM,
          backgroundColor: Colors.red,
          icon: Icons.highlight_off);
    }
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
                  "Alterar Imagem",
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
          elevation: 0,
          title: Image.asset(
            'images/logo.png',
            width: 120,
          ),
          centerTitle: true,
          backgroundColor: Colors.red[900],
        ),

        // TOLBAR NAVEGAÇÃO
        /* bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.black12,
          fixedColor: Colors.red[900],
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.business),
              activeIcon: Icon(
                Icons.home,
              ),
              title: Text('Home'),
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.people_outline), title: Text('Clientes')),
          ],
          currentIndex: selectedIndex,
          onTap: onItemTapped,
        ),*/
        drawer: Drawer(
          child: Container(
            color: Colors.black12,
            child: ListView(
              children: <Widget>[
                DrawerHeader(
                    padding: EdgeInsets.all(0),
                    child: Container(
                      padding: EdgeInsets.only(top: 15),
                      color: Colors.red[900],
                      child: Column(
                        children: <Widget>[
                          getImageWidget(),
                          Container(
                            padding: EdgeInsets.only(top: 5),
                            child: Text(
                              '${widget.nome_prof}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 2),
                            child: Text(
                              '${widget.email_banco}',
                              style: TextStyle(
                                color: Colors.red[50],
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 2),
                            child: Text(
                              '${widget.tipo}',
                              style: TextStyle(
                                color: Colors.red[50],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                Column(
                  children: <Widget>[
                    Container(
                      child: ListTile(
                        title: Text(
                          'Senha',
                          style: TextStyle(fontSize: 16),
                        ),
                        leading: Icon(
                          Icons.vpn_key,
                          color: Colors.red[900],
                          size: 25,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) => Senha()));
                        },
                      ),
                    ),
                    Divider(
                      height: 15,
                      color: Colors.red[900],
                    ),
                    Container(
                      child: ListTile(
                        title: Text(
                          'Ajuda',
                          style: TextStyle(fontSize: 16),
                        ),
                        leading: Icon(
                          Icons.help,
                          color: Colors.red[900],
                          size: 25,
                        ),
                        onTap: () {
                          _launchInWebViewWithJavaScript();
                        },
                      ),
                    ),
                    Divider(
                      height: 15,
                      color: Colors.red[900],
                    ),
                    Container(
                      child: ListTile(
                        title: Text(
                          'Sair',
                          style: TextStyle(fontSize: 16),
                        ),
                        leading: Icon(
                          Icons.exit_to_app,
                          color: Colors.red[900],
                          size: 25,
                        ),
                        onTap: () {
                          logoutUser();
                        },
                      ),
                    ),
                    Divider(
                      height: 15,
                      color: Colors.red[900],
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        body: bottomNavigationList.elementAt(selectedIndex));
  }
}
