import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
// import 'dart:convert';

class ApiCalendario {
  Future getAll() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String idProf = prefs.getString('idusu');

    return await http
        .get("http://focuseg.com.br/flutter/agenda_json.php?idProf=$idProf");
  }
}
