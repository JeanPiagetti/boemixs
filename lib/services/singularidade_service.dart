import 'dart:convert';
import 'package:boemix_app/model/singularidade.dart';
import 'package:http/http.dart' as http;

class SingularidadeService {

  String _baseUrl = 'https://aw-boemixs-api.herokuapp.com/api/singularidade/';
  List<Singularidade> _singularidades;

  Future<List<Singularidade>> retornaTodasSingularidades() async {
    http.Response response = await http.get(_baseUrl + "retornarSingularidade");
    if (response.statusCode == 200) {
      _singularidades = List<Singularidade>();
      Iterable lista = json.decode(response.body);
      _singularidades = lista.map((item) => Singularidade.fromJson(item)).toList();
      return _singularidades;
    } else {
      throw new Exception("Ocorreu um erro ao retornar esse objeto");
    }
  }

  Future<Singularidade> postSingularidade(Singularidade singularidade) async {
    var url = _baseUrl + "inserirSingularidade";
    print("Enviando requisicao POST para $url");
    var jsonParametros = json.encode(singularidade.toJson());
    http.Response response = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: jsonParametros);
    if(response.statusCode == 200) {
      print("Postado com sucesso JSON enviado ${jsonParametros}");
      return Singularidade.fromJson(json.decode(response.body));
    }else{
      return null;
    }
  }

  Future<bool> deleteSingular(int idSingularidade) async {
    var url = _baseUrl + "remover/$idSingularidade";
    print("Enviando requisição DELETE para $url");
    http.Response response = await http.delete(url);
    if (response.statusCode == 204) {
      print("Removido com sucesso!");
      return true;
    } else {
      return false;
    }
  }
}
