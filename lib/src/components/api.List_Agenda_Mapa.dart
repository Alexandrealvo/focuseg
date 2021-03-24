import 'package:http/http.dart' as http;

class API_LIST_MAPA_AGENDA {
  static Future getListMapa(String data_agendamento) async {
    //var url = url_mapa_agenda + idOs;
    var url = Uri.https('www.focuseg.com.br', '/flutter/list_agenda_json.php',
        {'data_agendamento': data_agendamento});
    return await http.get(url);
  }
}
