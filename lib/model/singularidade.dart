class Singularidade {
  int idSingularidade;
  String nomeSingularidade;

  Singularidade({this.idSingularidade, this.nomeSingularidade});

  Singularidade.fromJson(Map<String, dynamic> json) {
    idSingularidade = json['idSingularidade'];
    nomeSingularidade = json['nomeSingularidade'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['idSingularidade'] = this.idSingularidade;
    data['nomeSingularidade'] = this.nomeSingularidade;
    return data;
  }
}
