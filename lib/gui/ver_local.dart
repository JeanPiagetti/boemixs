import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:convert' show utf8;
import 'dart:typed_data';
import 'package:boemix_app/model/localizacao.dart';
import 'package:boemix_app/model/singularidade.dart';
import 'package:boemix_app/services/localizacao_service.dart';
import 'package:boemix_app/services/singularidade_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'busca.dart';

class VerLocal extends StatefulWidget {
  final Localizacao localizacao;

  VerLocal({this.localizacao});

  @override
  _VerLocalState createState() => _VerLocalState();
}

class _VerLocalState extends State<VerLocal> {
  final _nomeController = TextEditingController();
  final _descController = TextEditingController();
  final _imgController = TextEditingController();
  final _singController = TextEditingController();
  final _contatoController = TextEditingController();
  final _nameFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  File imagem;
  List<Singularidade> singularidades = [];
  Singularidade singularidade;
  LocalService services;
  SingularidadeService singularidadeService;
  Localizacao _editedLocal;

  @override
  void initState() {
    super.initState();
    services = LocalService();
    singularidade = Singularidade();
    singularidade.nomeSingularidade = _singController.text;
    singularidadeService = SingularidadeService();
    _preencheListaSingularidade();
    if (widget.localizacao == null) {
      _editedLocal = Localizacao();
    } else {
      _editedLocal = Localizacao.fromJson(widget.localizacao.toJson());
      _nomeController.text = utf8.decode(_editedLocal.nomeLocal.runes.toList());
      _descController.text = _editedLocal.descricaoLocal;
      _contatoController.text =
          utf8.decode(_editedLocal.contato.runes.toList());
      _imgController.text = _editedLocal.imagem;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        // onWillPop: _requestPop,

        child: Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.black45,
        title: Text(_editedLocal.nomeLocal == null
            ? "Nova Localização"
            : utf8.decode(_editedLocal.nomeLocal.runes.toList())),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(children: <Widget>[
              GestureDetector(
                  child: Container(
                    width: 300.0,
                    height: 300.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      image: DecorationImage(
                          image: _editedLocal.imagem != null
                              ? Image.memory(_decodificarImagem(_editedLocal.imagem))
                                  .image
                              : AssetImage("lib/images/SEM-IMAGEM-13.jpg"),
                          fit: BoxFit.scaleDown,repeat: ImageRepeat.repeatX),
                    ),
                  ),
                  onTap: () {
                    //preencher a tela do telefone

                  }),
              Form(
                  key: this._formKey,
                  child: TextFormField(
                    controller: _nomeController,
                    focusNode: _nameFocus,
                    enabled: false,
                    decoration: InputDecoration(labelText: "Nome"),
                  )),
              TextFormField(
                maxLines: 3,
                //autofocus: true,
                decoration: new InputDecoration(
                    labelText: 'Descrição do lugar:',
                    border: OutlineInputBorder(),
                    contentPadding: const EdgeInsets.all(10.0)),
                controller: _descController,
                enabled: false,
              ),
              Form(
                  child: TextFormField(
                decoration: InputDecoration(labelText: 'Contato do lugar: '),
                enabled: false,
                controller: _contatoController,
              )),
              Container(
                child: Row(children: <Widget>[
                  Expanded(
                      child: Form(
                          child: TextFormField(
                    controller: _singController,
                    enabled: false,
                    decoration: InputDecoration(
                        labelText: "Singularidade/Peculiaridade ",
                        contentPadding: EdgeInsets.all(10.0),
                        labelStyle: TextStyle(color: Colors.black)),
                  ))),
                ]),
              ),
              _listViewSingularidades()
            ])),
      ),
    ));
  }

/*
 * @TODO Verificar função ok
 * @TODO fazer a tela de ver e a singularidades
 */
  Uint8List _decodificarImagem(String imagem){
    return base64.decode(imagem);
  }
//  Image _retornaImagemDecodificada(Uint8List bytesImagem){
//    return
//  }
  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            onClosing: () {},
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                        child: Text(
                          "Excluir",
                          style: TextStyle(color: Colors.black, fontSize: 20.0),
                        ),
                        onPressed: () {
                          singularidadeService.deleteSingular(
                              singularidades[index].idSingularidade);
                          _scaffoldKey.currentState.showSnackBar(SnackBar(
                              content: Text(
                            "Removido com sucesso!",
                            style: TextStyle(fontSize: 15.0),
                          )));
                          setState(() {});
                          setState(() {
                            singularidades.removeAt(index);
                            Navigator.pop(context);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });
  }

  Widget _listViewSingularidades() {
    int index1 = 0;
    return GestureDetector(
        child: Row(
          children: <Widget>[
            Expanded(
              child: SizedBox(
                height: 200.0,
                child: new ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: 1,
                  itemBuilder: (BuildContext ctxt, index) {
                    return FlatButton(
                      child: Text(_editedLocal.singularidade.nomeSingularidade,
                          style: TextStyle(fontSize: 20.0)),
                      onPressed: () {
                        index1 = index;
                        print(
                            "Singularidade id e indice ${index}  ${singularidades[index].idSingularidade}");
                        _editedLocal.singularidade = singularidades[index];
                        print("Objeto a ser postado:{"
                            "Nome singularidade ${_editedLocal.singularidade.nomeSingularidade}, idLocalizacao  ${_editedLocal.idLocalizacao}, Nome Local ${_editedLocal.nomeLocal}");
                      },
                    );
                  },
                ),
              ),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
        onLongPress: () {
          _showOptions(context, index1);
        });
  }

  /*
    *@TODO escolha arquivo Ok
    */
  void _modalEscolherArquivo(BuildContext context) {
    final flatButtonColor = Theme.of(context).primaryColor;
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 150.0,
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Text(
                  'Escolher Imagem ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10.0,
                ),
                FlatButton(
                  textColor: flatButtonColor,
                  child: Text('Usar Camera'),
                  onPressed: () {
                    _getImage(context, ImageSource.camera);
                  },
                ),
                FlatButton(
                  textColor: flatButtonColor,
                  child: Text('Escolher imagem da Galeria'),
                  onPressed: () {
                    _getImage(context, ImageSource.gallery);
                  },
                ),
              ],
            ),
          );
        });
  }

  /*
    @TODO getImage Ok
     */
  void _getImage(BuildContext context, ImageSource source) async {
    File image = await ImagePicker.pickImage(source: source);
    setState(() {
      if (image != null) {
        _editedLocal.imagem = base64Encode(image.readAsBytesSync());
      } else {
        print("Não foi enviado imagem para o servidor");
      }

      // ByteData byteData = image.readAsBytesSync().buffer.asByteData();
      // print('Bytes da imagem $byteData');
    });
  }

/*
@TODO preenchimento de listas ok
 */
  void _preencheListaSingularidade() {
    singularidadeService.retornaTodasSingularidades().then((response) {
      setState(() {
        singularidades = response;
      });
      setState(() {});
    });
  }
}
