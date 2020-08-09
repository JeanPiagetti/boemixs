import 'dart:convert';
import 'package:boemix_app/gui/ver_local.dart';
import 'package:boemix_app/model/localizacao.dart';
import 'package:boemix_app/model/singularidade.dart';
import 'package:boemix_app/services/localizacao_service.dart';
import 'package:boemix_app/services/singularidade_service.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'busca_singular.dart';
import 'inserir_local.dart';

enum OrderOptions { orderaz, orderza }

// ignore: must_be_immutable
class Busca extends StatefulWidget {
  final String opcao;
  Singularidade singularidade;

  Busca(this.opcao, {this.singularidade});

  @override
  BuscaState createState() => BuscaState();
}

class Debouncer {
  final int milliseconds;
  VoidCallback action;
  Timer _timer;

  Debouncer({this.milliseconds});

  run(VoidCallback action) {
    if (null != _timer) {
      _timer.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class BuscaState extends State<Busca> {
  final _debouncer = Debouncer(milliseconds: 500);
  List<Localizacao> locais = List();
  List<Localizacao> locaisFiltrados = List();
  List<Singularidade> _listaSingularidade, singularidadeFiltrada = List();
  final LocalService services = LocalService();
  final SingularidadeService singularidadeService = SingularidadeService();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _preencherListas(String op) async {
    if (op.contains("Nome")) {
      await services.retornaTodosLocais().then((response) {
        setState(() {
          locais = response;
          locaisFiltrados = locais;
        });
      });
    } else {
      print('Selecionado Peculiaridade, preenchendo lista peculiaridades');
      await singularidadeService.retornaTodasSingularidades().then((response) {
        setState(() {
          _listaSingularidade = response;
          singularidadeFiltrada = _listaSingularidade;
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _preencherListas(this.widget.opcao);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.black45,
          title: Text("Busca por ${widget.opcao}"),
          actions: <Widget>[
            PopupMenuButton<OrderOptions>(
                itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
                      const PopupMenuItem<OrderOptions>(
                        child: Text("Ordenar de A-Z"),
                        value: OrderOptions.orderaz,
                      ),
                      const PopupMenuItem<OrderOptions>(
                        child: Text("Ordenar de Z-A"),
                        value: OrderOptions.orderza,
                      ),
                    ],
                onSelected: this.widget.opcao.contains("Nome")
                    ? _orderList
                    : orderSingularidade)
          ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => InserirLocal()));
        },
        backgroundColor: Colors.black,
        child: Icon(Icons.add),
      ),
      body: Column(
        children: <Widget>[
          TextField(
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(15.0),
              hintText: 'Filtrar por nome',
            ),
            onChanged: (string) {
              _debouncer.run(() {
                setState(() {
                  if (this.widget.opcao.contains("Nome")) {
                    locaisFiltrados = locais
                        .where((u) => (u.nomeLocal
                            .toLowerCase()
                            .contains(string.toLowerCase())))
                        .toList();
                  } else {
                    singularidadeFiltrada = _listaSingularidade
                        .where((u) => u.nomeSingularidade
                            .toLowerCase()
                            .contains(string.toLowerCase()))
                        .toList();
                  }
                });
              });
            },
          ),
          Expanded(
            child: ListView.builder(
                padding: EdgeInsets.all(10.0),
                itemCount: this.widget.opcao.contains("Nome")
                    ? locaisFiltrados.length
                    : singularidadeFiltrada.length,
                itemBuilder: (BuildContext context, int index) {
                  return _cartaoOpcoes(context, index, this.widget.opcao);
                }),
          ),
        ],
      ),
    );
  }

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
                          "Ver",
                          style: TextStyle(color: Colors.black, fontSize: 20.0),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => VerLocal(
                                      localizacao: locaisFiltrados[index])));
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                        child: Text(
                          "Editar",
                          style: TextStyle(color: Colors.black, fontSize: 20.0),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _showLocalPage(localizacao: locais[index]);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                        child: Text(
                          "Excluir",
                          style: TextStyle(color: Colors.black, fontSize: 20.0),
                        ),
                        onPressed: () {
                          services
                              .deleteLocal(locaisFiltrados[index].idLocalizacao)
                              .then((response) {
                            setState(() {
                              if (response) {
                                locais.removeAt(index);
                                _scaffoldKey.currentState.showSnackBar(SnackBar(
                                    content: Text("Removido com sucesso !")));
                                Navigator.pop(context);
                              } else {
                                _scaffoldKey.currentState.showSnackBar(SnackBar(
                                    content:
                                        Text("Não pode remover esse local ")));
                              }
                            });
                          });
                          setState(() {});

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

  void _showLocalPage({Localizacao localizacao}) async {
    final editadoLocalizacao = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => InserirLocal(localizacao: localizacao)));
    if (editadoLocalizacao != null) {
      if (localizacao != null) {
        //await services.updateLocal(editadoLocalizacao);
      } else {
        await services.postLocalizacao(editadoLocalizacao);
        setState(() {
          _preencherListas(this.widget.opcao);
        });
      }
    }
  }
//ok
  void _orderList(OrderOptions result) {
    switch (result) {
      case OrderOptions.orderaz:
        locais.sort((a, b) {
          return a.nomeLocal.toLowerCase().compareTo(b.nomeLocal.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        locais.sort((a, b) {
          return b.nomeLocal.toLowerCase().compareTo(a.nomeLocal.toLowerCase());
        });
        setState(() {});
        break;
    }
    setState(() {});
  }

  void orderSingularidade(OrderOptions result) {
    switch (result) {
      case OrderOptions.orderaz:
        _listaSingularidade.sort((a, b) {
          return a.nomeSingularidade
              .toLowerCase()
              .compareTo(b.nomeSingularidade.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        _listaSingularidade.sort((a, b) {
          return b.nomeSingularidade
              .toLowerCase()
              .compareTo(a.nomeSingularidade.toLowerCase());
        });
        break;
    }
    setState(() {});
  }

  Widget _cartaoOpcoes(BuildContext context, int index, String opcao,
      {String nomeSingularidade}) {
    switch (opcao) {
      case "Nome":
        print(
            "Singularidade vazia mostrando cards de localizacao sem filtragem");
        return GestureDetector(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Wrap(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(
                        height: 100.0,
                        child: locaisFiltrados[index].imagem != null
                            ? Image.memory(
                                (base64Decode(locaisFiltrados[index].imagem)),
                                fit: BoxFit.cover,
                              )
                            : Image.asset('lib/images/SEM-IMAGEM-13.jpg',
                                fit: BoxFit.scaleDown),
                      )
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Column(
                      //crossAxisAlignment: WrapCrossAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          locaisFiltrados[index].nomeLocal == null
                              ? "Sem Nome"
                              : locaisFiltrados[index].nomeLocal,
                          style: TextStyle(
                              fontSize: 22.0, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          locaisFiltrados[index].descricaoLocal == null
                              ? "Sem descrição"
                              : locaisFiltrados[index].descricaoLocal.substring(
                                      0,
                                      locaisFiltrados[index]
                                              .descricaoLocal
                                              .length ~/2) +
                                  " Toque para ver mais",
                          style: TextStyle(fontSize: 18.0,fontStyle: FontStyle.italic,color: Colors.black),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          onTap: () {
            _showOptions(context, index);
          },
        );
        break;

      case "Peculiaridade":
        return GestureDetector(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Wrap(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        Text(
                          singularidadeFiltrada[index].nomeSingularidade ?? "",
                          style: TextStyle(
                              fontSize: 22.0, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          onTap: () {
            _showOptionsPeculiar(
                context, index, singularidadeFiltrada[index].nomeSingularidade);
          },
        );
        break;
    }
  }

  Widget _listarLocaisPeculiaridade(int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Wrap(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    height: 100.0,
                    child: locaisFiltrados[index].imagem != null
                        ? Image.memory(
                            (base64Decode(locaisFiltrados[index].imagem)),
                            fit: BoxFit.cover,
                          )
                        : Image.asset('lib/images/SEM-IMAGEM-13.jpg',
                            fit: BoxFit.scaleDown),
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      locaisFiltrados[index].nomeLocal == null
                          ? "Sem Nome"
                          : locaisFiltrados[index].nomeLocal,
                      style: TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      locaisFiltrados[index].descricaoLocal == null
                          ? "Sem descrição"
                          : locaisFiltrados[index].descricaoLocal.substring(
                                  0,
                                  locaisFiltrados[index]
                                          .descricaoLocal
                                          .length ~/
                                      2) +
                              "   Toque para ver mais",
                      style: TextStyle(fontSize: 15.0),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      onTap: () {
        // _showOptions(context, index);
      },
    );
  }

  void _showOptionsPeculiar(
      BuildContext context, int index, String nomeSingularidade) {
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
                              "Ver",
                              style: TextStyle(
                                  color: Colors.black, fontSize: 20.0),
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          BuscaPorSingularidade(
                                              singularidadeFiltrada[index])));
                            })),
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
                                  _listaSingularidade[index].idSingularidade)
                              .then((response) {
                            setState(() {
                              if (response) {
                                _listaSingularidade.removeAt(index);
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
}
