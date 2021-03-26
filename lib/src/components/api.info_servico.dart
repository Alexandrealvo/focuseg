import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

//const url_api = "https://focuseg.com.br/flutter/chamadas_json.php?idProf=";

class API_INFO_SERV {
  static Future getInfoServ() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String idOs = prefs.getString('idOs');
    var url = Uri.https(
        'www.focuseg.com.br', '/flutter/info_servico_json.php', {'idOs': idOs});
    return await http.get(url);
  }
}
