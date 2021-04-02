import 'package:http/http.dart' as http;

class ApiListMapaAgenda {
  static Future getListMapa(String dataAgendamento) async {
    //var url = url_mapa_agenda + idOs;
    var url = Uri.https('www.focuseg.com.br', '/flutter/list_agenda_json.php',
        {'data_agendamento': dataAgendamento});
    return await http.get(url);
  }
}
