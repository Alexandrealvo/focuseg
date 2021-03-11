import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

//const url_serv = "https://focuseg.com.br/flutter/servicos_json.php?idProf=";

class API_SERV {
  static Future getServicos() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String idProf = prefs.getString('idusu');
    //var url = url_serv + idProf;
    var url = Uri.https(
        'www.focuseg.com.br', '/flutter/servicos_json.php', {'idProf': idProf});
    return await http.get(url);
  }
}
