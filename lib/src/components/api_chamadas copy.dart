import 'package:http/http.dart' as http;

//const url_api = "https://focuseg.com.br/flutter/chamadas_json.php?idProf=";

class API {
  static Future getChamadas(idOs) async {
    var url = Uri.https(
        'www.focuseg.com.br', '/flutter/info_servico_json.php', {'idOs': idOs});
    return await http.get(url);
  }
}
