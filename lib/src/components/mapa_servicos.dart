class Dados_Servicos {
  String idos;
  String nome_cliente;
  String data_create;
  String endereco;
  String tipos;
  String idProf;
  String idServ;
  String status;
  String dt_agenda;
  String info_checkin;
  String info_checkout;

  Dados_Servicos(
      String idos,
      String nome_cliente,
      String data_create,
      String endereco,
      String tipos,
      String idProf,
      String idServ,
      String status,
      String dt_agenda,
      String info_checkin,
      String info_checkout) {
    this.idos = idos;
    this.nome_cliente = nome_cliente;
    this.data_create = data_create;
    this.endereco = endereco;
    this.tipos = tipos;
    this.idProf = idProf;
    this.idServ = idServ;
    this.status = status;
    this.dt_agenda = dt_agenda;
    this.info_checkin = info_checkin;
    this.info_checkout = info_checkout;
  }
  Dados_Servicos.fromJson(Map json)
      : idos = json['idos'],
        nome_cliente = json['nome_cliente'],
        data_create = json['data_create'],
        endereco = json['endereco'],
        tipos = json['tipos'],
        idProf = json['idProf'],
        idServ = json['idServ'],
        status = json['status'],
        dt_agenda = json['dt_agenda'],
        info_checkin = json['info_checkin'],
        info_checkout = json['info_checkout'];
}
