class DadosAgenda {
  String idos;
  String cliente;
  String endereco;
  String idProf;
  String lat;
  String lng;

  DadosAgenda(String idos, String cliente, String endereco, String idProf,
      String lat, String lng) {
    this.idos = idos;
    this.cliente = cliente;
    this.endereco = endereco;
    this.idProf = idProf;
    this.lat = lat;
    this.lng = lng;
  }
  DadosAgenda.fromJson(Map json)
      : idos = json['idos'],
        cliente = json['cliente'],
        endereco = json['endereco'],
        idProf = json['idProf'],
        lat = json['lat'],
        lng = json['lng'];
}
