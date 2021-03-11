import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
// import 'dart:convert';

class ApiCalendario {
  Future getAll() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String idProf = prefs.getString('idusu');

    var url = Uri.https('www.focuseg.com.br', '/flutter/mapa_agenda_json.php',
        {'idProf': idProf});
    return await http.get(url);
  }
}
