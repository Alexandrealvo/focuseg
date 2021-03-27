class Dados_Clientes {
  String idcliente;
  String nome_cliente;
  String endereco;
  String bairrocidade;
  String tel;
  String cel;
  String latlng;
  String tipo;
  String lat;
  String lng;

  Dados_Clientes(
      String idcliente,
      String nome_cliente,
      String endereco,
      String bairrocidade,
      String tel,
      String cel,
      String latlng,
      String tipo,
      String lat,
      String lng) {
    this.idcliente = idcliente;
    this.nome_cliente = nome_cliente;
    this.endereco = endereco;
    this.bairrocidade = bairrocidade;
    this.tel = tel;
    this.cel = cel;
    this.latlng = latlng;
    this.tipo = tipo;
    this.lat = lat;
    this.lng = lng;
  }
  Dados_Clientes.fromJson(Map json)
      : idcliente = json['idcliente'],
        nome_cliente = json['nome_cliente'],
        endereco = json['endereco'],
        bairrocidade = json['bairrocidade'],
        tel = json['tel'],
        cel = json['cel'],
        latlng = json['latlng'],
        tipo = json['tipo'],
        lat = json['lat'],
        lng = json['lng'];
}
