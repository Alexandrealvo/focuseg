import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

//const url_api = "https://focuseg.com.br/flutter/chamadas_json.php?idProf=";

class API {
  static Future getClientes() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String idProf = prefs.getString('idusu');
    //var url = url_api + idProf;
    var url = Uri.https(
        'www.focuseg.com.br', '/flutter/clientes_json.php', {'idProf': idProf});
    return await http.get(url);
  }
}
