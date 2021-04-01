import 'package:connectivity/connectivity.dart';
import 'package:edge_alert/edge_alert.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:focus/src/pages/home_page.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:http/http.dart' as http;
import 'dart:ui';
import 'dart:async';
import 'dart:convert';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

/*class BlocHome {
  void initOneSignal() {
    OneSignal.shared.init("2cffbe8e-b022-4b1a-84b2-571b54662f4b");
    OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.none);
  }
}*/

//const urlcondo = "https://www.focuseg.com.br/flutter/login_json.php";

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
// variaveis
  //var bloc = BlocHome();
  final email = new TextEditingController();
  final senha = new TextEditingController();
  final focusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  //final Connectivity _connectivity = Connectivity();
  //StreamSubscription<ConnectivityResult> _connectivitySubscription;

  //String _connection = "";
  bool isLoading = false;
  bool isLoggedIn = false;

  @override
  void initState() {
    // bloc.initOneSignal();
    super.initState();
    _updateStatus();
    authenticate();
  }

  authenticate() async {
    if (await _isBiometricAvailable()) {
      await _getListOfBiometricTypes();
      await autoLogIn();
    }
  }

  Future<bool> _isBiometricAvailable() async {
    bool isAvailable = await _localAuthentication.canCheckBiometrics;
    return isAvailable;
  }

  Future<void> _getListOfBiometricTypes() async {
    List<BiometricType> listOfBiometrics =
        await _localAuthentication.getAvailableBiometrics();
    return listOfBiometrics;
  }

  Future<void> autoLogIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String id = prefs.getString('idusu');

    if (id != null) {
      bool isAuthenticated = await _localAuthentication.authenticate(
        localizedReason: "Autenticar para realizar Login na plataforma",
        useErrorDialogs: true,
        stickyAuth: true,
      );
      if (isAuthenticated) {
        setState(() {
          isLoading = false;
        });
        final String nome = prefs.getString('nome');
        final String tipo = prefs.getString('tipo');
        final String imgperfil = prefs.getString('imgperfil');
        final String email = prefs.getString('email');

        OneSignal.shared.sendTags({
          "nome": prefs.getString('nome'),
          "idusu": prefs.getString('idusu')
        });

        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) =>
                    HomePage(id, nome, tipo, imgperfil, email)),
            (Route<dynamic> route) => false);
      } else {
        setState(() {
          isLoading = false;
        });
        return;
      }
    }
  }

  void _updateStatus() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
    } else {
      EdgeAlert.show(context,
          title: 'Sem conexão com internet...',
          gravity: EdgeAlert.BOTTOM,
          duration: 3,
          backgroundColor: Colors.red,
          icon: Icons.highlight_off);
    }
    Timer(
      Duration(seconds: 15),
      () => _updateStatus(),
    );
  }

  Future<List> _login() async {
    final response = await http.post(
        Uri.https("www.focuseg.com.br", '/flutter/login_json.php'),
        body: {
          "email": email.text,
          "senha": senha.text,
        });

    var dados_usuario = json.decode(response.body);

    if (dados_usuario['valida'] == 1) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      OneSignal.shared.sendTags(
          {"nome": dados_usuario['nome'], "idusu": dados_usuario['idusu']});

      prefs.setString('idusu', dados_usuario['idusu']);
      prefs.setString('nome', dados_usuario['nome']);
      prefs.setString('tipo', dados_usuario['tipo']);
      prefs.setString('email', dados_usuario['email']);
      prefs.setString('imgperfil', dados_usuario['imgperfil']);

      setState(() {
        isLoggedIn = true;
        isLoading = false;
      });

      autoLogIn();
    } else {
      setState(() {
        isLoading = false;
      });
      _onAlertButtonPressed(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, //use this
      body: SingleChildScrollView(child: main()),
    );
  }

  Stack main() {
    return Stack(
      children: <Widget>[
        Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: Colors.red[900],
            ),
            child: Column(children: <Widget>[
              Center(
                child: Container(
                  padding: const EdgeInsets.only(top: 100),
                  child: Image.asset(
                    "images/logo.png",
                    fit: BoxFit.fill,
                    width: 150,
                  ),
                ),
              ),
            ])),
        Positioned(
          top: 200,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(60),
                  topRight: Radius.circular(60),
                )),
          ),
        ),
        isLoading
            ? Container(
                height: MediaQuery.of(context).size.height,
                color: Colors.black.withOpacity(0.5),
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
                children: <Widget>[
                  Center(
                    child: Form(
                      //autovalidate: true,
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(20, 310, 20, 20),
                            child: Container(
                              //color: Color(0xfff5f5f5),
                              child: TextFormField(
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'SFUIDisplay'),
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.red[900], width: 3.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide:
                                            BorderSide(color: Colors.white)),
                                    labelText: 'Entre com seu e-mail',
                                    prefixIcon: Icon(Icons.mail_outline,
                                        color: Colors.white),
                                    labelStyle: TextStyle(
                                        color: Colors.white, fontSize: 16)),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value_email) {
                                  if (!EmailValidator.validate(value_email)) {
                                    return 'Entre com e-mail válido!';
                                  }
                                },
                                controller: email,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 50),
                            child: Container(
                              //color: Color(0xfff5f5f5),
                              child: TextFormField(
                                obscureText: true,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'SFUIDisplay'),
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.red[900], width: 3.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide:
                                            BorderSide(color: Colors.white)),
                                    labelText: 'Entre com a senha',
                                    prefixIcon: Icon(Icons.lock_outline,
                                        color: Colors.white),
                                    labelStyle: TextStyle(
                                        color: Colors.white, fontSize: 16)),
                                validator: (value_senha) {
                                  if (value_senha.isEmpty) {
                                    return 'Campo senha vazio!';
                                  }
                                  return null;
                                },
                                controller: senha,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                            child: ButtonTheme(
                              height: 50.0,
                              child: RaisedButton(
                                onPressed: () {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  _login();
                                },
                                shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(10.0)),
                                child: Text(
                                  "Entrar",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                                color: Colors.red[900],
                              ),
                            ),
                          ),
                          new Padding(
                            padding: EdgeInsets.fromLTRB(0, 10, 0, 30),
                            child: FlatButton(
                              textColor: Colors.white,
                              disabledColor: Colors.grey,
                              disabledTextColor: Colors.black,
                              splashColor: Colors.red[900],
                              onPressed: () {},
                              child: Text(
                                "Esqueceu a senha?",
                                style: TextStyle(shadows: [
                                  Shadow(
                                    blurRadius: 8.0,
                                    color: Colors.red,
                                    offset: Offset(0.0, 2.0),
                                  ),
                                ], fontSize: 12.0),
                                textDirection: TextDirection.ltr,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ],
    );
  }
}

var alertStyle = AlertStyle(
  animationType: AnimationType.fromTop,
  isCloseButton: false,
  isOverlayTapDismiss: false,
  //descStyle: TextStyle(color: Colors.red,),
  animationDuration: Duration(milliseconds: 300),
  titleStyle: TextStyle(
    color: Colors.black,
    fontSize: 18,
  ),
);

_onAlertButtonPressed(context) {
  Alert(
    image: Icon(
      Icons.highlight_off,
      color: Colors.red,
      size: 60,
    ),
    style: alertStyle,
    context: context,
    title: "E-mail ou senha inválidos!\n Tente novamente.",
    buttons: [
      DialogButton(
        child: Text(
          "OK",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        onPressed: () => Navigator.pop(context),
        width: 80,
        color: Colors.red,
      )
    ],
  ).show();
}
