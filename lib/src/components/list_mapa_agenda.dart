class DadosAgendaMapa {
  String idos;
  String data_agenda;

  DadosAgendaMapa(String idos, String data_agenda) {
    this.idos = idos;
    this.data_agenda = data_agenda;
  }
  DadosAgendaMapa.fromJson(Map json)
      : idos = json['idos'],
        data_agenda = json['data_agenda'];
}
