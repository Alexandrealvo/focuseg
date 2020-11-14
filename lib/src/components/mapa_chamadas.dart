class Dados_Chamadas {
  String idos;
  String nome_cliente;
  String data_create;
  String endereco;
  String tipos;
  String idProf;

  Dados_Chamadas(String idos, String nome_cliente, String data_create,
      String endereco, String tipos, String idProf) {
    this.idos = idos;
    this.nome_cliente = nome_cliente;
    this.data_create = data_create;
    this.endereco = endereco;
    this.tipos = tipos;
    this.idProf = idProf;
  }
  Dados_Chamadas.fromJson(Map json)
      : idos = json['idos'],
        nome_cliente = json['nome_cliente'],
        data_create = json['data_create'],
        endereco = json['endereco'],
        tipos = json['tipos'],
        idProf = json['idProf'];
}
