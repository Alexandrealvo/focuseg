class DadosAgenda {
  String idos;
  String cliente;
  String endereco;
  String idProf;
  String latlng;

  DadosAgenda(String idos, String cliente, String endereco, String idProf,
      String latlng) {
    this.idos = idos;
    this.cliente = cliente;
    this.endereco = endereco;
    this.idProf = idProf;
    this.latlng = latlng;
  }
  DadosAgenda.fromJson(Map json)
      : idos = json['idos'],
        cliente = json['cliente'],
        endereco = json['endereco'],
        idProf = json['idProf'],
        latlng = json['latlng'];
}
