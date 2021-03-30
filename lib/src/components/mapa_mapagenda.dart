class DadosAgenda {
  String idos;
  String cliente;
  String endereco;
  String idProf;
  String lat;
  String lng;
  String status;
  String ctlcheckin;
  String ctlcheckout;
  String imgperfil;

  DadosAgenda(
      String idos,
      String cliente,
      String endereco,
      String idProf,
      String lat,
      String lng,
      String status,
      String ctlcheckin,
      String ctlcheckout,
      String imgperfil) {
    this.idos = idos;
    this.cliente = cliente;
    this.endereco = endereco;
    this.idProf = idProf;
    this.lat = lat;
    this.lng = lng;
    this.status = status;
    this.ctlcheckin = ctlcheckin;
    this.ctlcheckout = ctlcheckout;
    this.imgperfil = imgperfil;
  }
  DadosAgenda.fromJson(Map json)
      : idos = json['idos'],
        cliente = json['cliente'],
        endereco = json['endereco'],
        idProf = json['idProf'],
        lat = json['lat'],
        lng = json['lng'],
        status = json['status'],
        ctlcheckin = json['ctlcheckin'],
        ctlcheckout = json['ctlcheckout'],
        imgperfil = json['imgperfil'];
}
