class Dados_Info_Serv {
  String idos;
  String nome_cliente;
  String data_create;
  String endereco;
  String tipos;
  String idProf;
  String idServ;
  String status;
  String dt_agenda;
  String checkin;
  String checkout;
  String imgserv;
  String obs;

  Dados_Info_Serv(
      String idos,
      String nome_cliente,
      String data_create,
      String endereco,
      String tipos,
      String idProf,
      String idServ,
      String status,
      String dt_agenda,
      String checkin,
      String checkout,
      String imgserv,
      String obs) {
    this.idos = idos;
    this.nome_cliente = nome_cliente;
    this.data_create = data_create;
    this.endereco = endereco;
    this.tipos = tipos;
    this.idProf = idProf;
    this.idServ = idServ;
    this.status = status;
    this.dt_agenda = dt_agenda;
    this.checkin = checkin;
    this.checkout = checkout;
    this.imgserv = imgserv;
    this.obs = obs;
  }
  Dados_Info_Serv.fromJson(Map json)
      : idos = json['idos'],
        nome_cliente = json['nome_cliente'],
        data_create = json['data_create'],
        endereco = json['endereco'],
        tipos = json['tipos'],
        idProf = json['idProf'],
        idServ = json['idServ'],
        status = json['status'],
        dt_agenda = json['dt_agenda'],
        checkin = json['checkin'],
        checkout = json['checkout'],
        imgserv = json['imgserv'],
        obs = json['obs'];
}
