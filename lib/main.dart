import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:focus/login.dart';
import 'package:focus/src/components/home_widget_bottomtab.dart';
import 'package:focus/src/components/senha.dart';
import 'package:focus/src/pages/calendario.dart';
import 'package:focus/src/pages/chamadas.dart';
import 'package:focus/src/pages/mapa.dart';
import 'package:focus/src/pages/servicos.dart';
import 'login.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: [Locale('pt')],
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => Login(),
        '/home': (context) => HomeBottomTab(),
        '/login': (context) => Login(),
        '/senha': (context) => Senha(),
        '/chamadas': (context) => Chamadas(),
        '/servicos': (context) => Servicos(),
        '/calendario': (context) => Calendario(),
        '/mapa': (context) => Mapa(),
      },
    );
  }
}
