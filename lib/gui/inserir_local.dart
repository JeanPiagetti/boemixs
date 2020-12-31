import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:convert' show utf8;
import 'package:boemix_app/model/localizacao.dart';
import 'package:boemix_app/model/singularidade.dart';
import 'package:boemix_app/services/localizacao_service.dart';
import 'package:boemix_app/services/singularidade_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'busca.dart';

class InserirLocal extends StatefulWidget {
  final Localizacao localizacao;

  InserirLocal({this.localizacao});

  @override
  _InserirLocalState createState() => _InserirLocalState();
}

class _InserirLocalState extends State<InserirLocal> {
  final _nomeController = TextEditingController();
  final _descController = TextEditingController();
  final _imgController = TextEditingController();
  final _singController = TextEditingController();
  final _contatoController = TextEditingController();
  final _nameFocus = FocusNode();
  final _formKeyNome = GlobalKey<FormState>();
  final _formKeySing = GlobalKey<FormState>();
  final _formContatoKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  File imagem;
  List<Singularidade> singularidades = [];
  Singularidade singularidade;
  bool _userEdited = false;
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
        onWillPop: _requestPop,
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            backgroundColor: Colors.black45,
            title: Text(_editedLocal.nomeLocal == null
                ? "Nova Localização"
                : utf8.decode(_editedLocal.nomeLocal.runes.toList())),
            centerTitle: true,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              if (_formKeyNome.currentState.validate() &&
                      _formKeySing.currentState.validate() ||
                  _formContatoKey.currentState.validate()) {
                await services.postLocalizacao(_editedLocal).then((response) {
                  setState(() {
                    if (response) {
                      _scaffoldKey.currentState.showSnackBar(SnackBar(
                        content: Text("Cadastro efetuado com sucesso "),
                        duration: Duration(seconds: 3),
                      ));
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Busca("Nome")));
                    }
                  });
                });
              } else {
                _scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text("Preencha os campos,por favor"),
                    duration: Duration(seconds: 3)));
              }
            },
            child: Icon(Icons.save),
            backgroundColor: Colors.black,
          ),
          body: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(children: <Widget>[
                  GestureDetector(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 400.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          image: DecorationImage(
                              image: _editedLocal.imagem != null
                                  ? Image.memory(base64.decode(
                                          _editedLocal.imagem))
                                      .image
                                  : AssetImage("lib/images/SEM-IMAGEM-13.jpg"),
                              fit: BoxFit.fitHeight),
                        ),
                      ),
                      onTap: () {
                        _modalEscolherArquivo(context);
                      }),
                  Form(
                      key: _formKeyNome,
                      child: TextFormField(
                        controller: _nomeController,
                        focusNode: _nameFocus,
                        decoration: InputDecoration(labelText: "Nome"),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Infome um nome por favor';
                          }
                        },
                        onChanged: (text) {
                          _userEdited = true;
                          setState(() {
                            _editedLocal.nomeLocal =
                                utf8.decode(text.runes.toList());
                          });
                        },
                      )),
                  TextFormField(
                    maxLines: 3,
                    decoration: new InputDecoration(
                        labelText: 'Descrição do lugar:',
                        contentPadding: const EdgeInsets.all(1.0)),
                    controller: _descController,
                    onChanged: (text) {
                      _userEdited = true;
                        setState(() {
                          _editedLocal.descricaoLocal = utf8.decode(text.runes.toList());
                        });
                    },
                    keyboardType: TextInputType.text,
                  ),
                  Form(
                      key: _formContatoKey,
                      child: TextFormField(
                        controller: _contatoController,
                        decoration:
                            InputDecoration(labelText: 'Contato do local: '),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Informe um contato por favor';
                          }
                        },
                        onChanged: (text) {
                          _userEdited = true;
                          setState(() {
                            _editedLocal.contato =
                                utf8.decode(text.runes.toList());
                          });
                        },
                      )),
                  Container(
                    child: Row(children: <Widget>[
                      Expanded(
                          child: Form(
                              key: _formKeySing,
                              child: TextFormField(
                                controller: _singController,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Informe uma peculiaridade por favor';
                                  }
                                },
                                decoration: InputDecoration(
                                    labelText: "Singularidade/Peculiaridade ",
                                    labelStyle:
                                        TextStyle(color: Colors.black45)),
                                onChanged: (text) {
                                  _userEdited = true;
                                  singularidade.nomeSingularidade = text;
                                },
                              ))),
                      RaisedButton(
                          color: Colors.black,
                          child: Icon(Icons.add),
                          textColor: Colors.white,
                          shape: CircleBorder(),
                          onPressed: () {
                            if (_formKeySing.currentState.validate()) {
                              singularidadeService.postSingularidade(singularidade).then((response) {
                                if (response != null) {
                                  setState(() {
                                    singularidades.add(response);
                                    _preencheListaSingularidade();
                                    _listViewSingularidades();
                                  });
                                  _scaffoldKey.currentState.showSnackBar(SnackBar(
                                      content: Text(
                                          "Peculiaridade Cadastrada com sucesso!")));
                                }
                              });
                            }
                            setState(() {});
                          }),
                    ]),
                  ),
                  _listViewSingularidades()
                ])),
          ),
        ));
  }

  void _showOptionsPeculiar(BuildContext context, int index) {
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
                          singularidadeService
                              .deleteSingular(
                                  singularidades[index].idSingularidade)
                              .then((response) {
                            setState(() {
                              if (response) {
                                singularidades.removeAt(index);
                                Navigator.pop(context);
                                _scaffoldKey.currentState.showSnackBar(SnackBar(
                                    content: Text("Removido com sucesso!")));
                              } else {
                                Navigator.pop(context);
                                _scaffoldKey.currentState.showSnackBar(SnackBar(
                                    content:
                                        Text("Não foi possível remover ")));
                              }
                            });
                          });
                          setState(() {});
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
                        itemCount: singularidades.length,
                        itemBuilder: (BuildContext ctxt, index) {
                          return RadioListTile(
                            value: singularidade,
                            groupValue: singularidades[index],
                            secondary: Icon(Icons.local_activity),
                            onChanged: (Singularidade s) {
                              setState(() {
                                index1 = index;
                                singularidade = singularidades[index];
                                _editedLocal.singularidade = singularidade;
                              });
                            },

                            activeColor: Colors.black,
                            title: Text(
                                "${singularidades[index].nomeSingularidade}"),
                          );
                        })))
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
        onLongPress: () {
          _showOptionsPeculiar(context, index1);
        });
  }

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

  void _getImage(BuildContext context, ImageSource source) async {
    File image = await ImagePicker.pickImage(source: source);
    setState(() {
      if (image != null) {
        _editedLocal.imagem = base64Encode(image.readAsBytesSync());
      }
    });
  }

  void _preencheListaSingularidade() {
    singularidadeService.retornaTodasSingularidades().then((response) {
      setState(() {
        singularidades = response;
      });
      setState(() {});
    });
  }

  Future<bool> _requestPop() {
    if (_userEdited) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Descartar Alterações?"),
              content: Text("Se sair as alterações serão perdidas."),
              actions: <Widget>[
                FlatButton(
                  child: Text("Cancelar"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text("Sim"),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

}
