import 'dart:convert';
import 'package:boemix_app/model/localizacao.dart';
import 'package:http/http.dart' as http;

class LocalService {
// static final String IP_ADRESS = "192.168.1.7";

//  static final String IP_ADRESS = "10.2.170.104";
  String _baseUrl = "https://aw-boemixs-api.herokuapp.com/api/";
  List<Localizacao> locais;

  Future<List<Localizacao>> retornaTodosLocais() async {
    http.Response response = await http.get(_baseUrl + "localizar");
    try {
      if (response.statusCode == 200) {
        locais = List<Localizacao>();
        Iterable lista = json.decode(response.body);
        locais = lista.map((item) => Localizacao.fromJson(item)).toList();
        return locais;
      } else {
        throw new Exception("Ocorreu um erro");
      }
    } catch (e) {}
  }

  Future<Localizacao> retornaLocalizacao(int id) async {
    http.Response response = await http.get(_baseUrl + "localizar/$id");
    try {
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw new Exception("Ocorreu um erro ao retornar a localizacao");
      }
    } catch (e) {}
  }

  Future<bool> postLocalizacao(Localizacao localizacao) async {
    var url = _baseUrl + "inserirObjeto";
    print("Enviando requisicao POST para $url");
    http.Response response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        encoding: Utf8Codec(),
        body: json.encode(localizacao.toJson()));
    if (response.statusCode == 200) {
      print('Código de resposta ${response.statusCode}');
      return true;
    } else {
      print('codigo de resposta ${response.statusCode}');
      return false;
    }
  }

  Future<bool> deleteLocal(int idLocal) async {
    var url = _baseUrl + "remover/$idLocal";
    http.Response response = await http.delete(url);
    if (response.statusCode == 204) {
      print('Deletado com sucesso');
      return true;
    } else {
      print('Erro ao deletar');
      return false;
    }
  }

//  Future<Map<String, dynamic>> postLocalImagem(
//      Localizacao localizacao) async {
//    try{
//    final mimeTypeData =lookupMimeType(localizacao.imagem.path, headerBytes: [0xFF, 0xD8]).split('/');
//      final imageRequest =http.MultipartRequest('POST', Uri.parse(_baseUrl + "inserirObjeto"));
//    final file = await http.MultipartFile.fromPath('imagem', localizacao.imagem.path,
//        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));
//    imageRequest.fields['localizacao'] = json.encode(localizacao.toJson());
//    imageRequest.fields['imagem'] = mimeTypeData[1];
//    imageRequest.files.add(file);
//
//      final http.StreamedResponse streamedResponse = await imageRequest.send();
//      final http.Response response = await http.Response.fromStream(streamedResponse);
//      //200 = OK
//      print(response.body);
//      if (response.statusCode != 200) {
//        throw new Exception("Não foi possivel efetuar a operação");
//      }
//      final Map<String, dynamic> responseData = json.decode(response.body);
//      return responseData;
//    } catch (e) {
//      print(e);
//      //return null;
//    }
//  }
}
