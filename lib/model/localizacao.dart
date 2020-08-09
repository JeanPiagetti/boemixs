import 'package:boemix_app/model/singularidade.dart';

class Localizacao {
  int idLocalizacao;
  String nomeLocal;
  String descricaoLocal;
  Singularidade singularidade;
  String imagem;
  String contato;

  Localizacao(
      {this.idLocalizacao,
        this.nomeLocal,
        this.descricaoLocal,
        this.singularidade,
        this.imagem,
        this.contato});

  Localizacao.fromJson(Map<String, dynamic> json) {
    idLocalizacao = json['idLocalizacao'];
    nomeLocal = json['nomeLocal'];
    descricaoLocal = json['descricaoLocal'];
    singularidade = json['singularidade'] != null
        ? new Singularidade.fromJson(json['singularidade'])
        : null;
    imagem = json['image'];
    contato = json['contato'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['idLocalizacao'] = this.idLocalizacao;
    data['nomeLocal'] = this.nomeLocal;
    data['descricaoLocal'] = this.descricaoLocal;
    if (this.singularidade != null) {
      data['singularidade'] = this.singularidade.toJson();
    }
    data['image'] = this.imagem;
    data['contato'] = this.contato;
    return data;
  }
}


