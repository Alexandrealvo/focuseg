import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

//const url_mapa_agenda ="https://focuseg.com.br/flutter/mapa_agenda_json.php?idOs=";

class ApiMapaAgenda {
  static Future getMapaAgenda() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String idOs = prefs.getString('idOs');
    //var url = url_mapa_agenda + idOs;
    var url = Uri.https(
        'www.focuseg.com.br', '/flutter/mapa_agenda_json.php', {'idOs': idOs});
    return await http.get(url);
  }
}
