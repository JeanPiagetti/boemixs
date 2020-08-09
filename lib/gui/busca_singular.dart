import 'dart:convert';
import 'package:boemix_app/gui/ver_local.dart';
import 'package:boemix_app/model/localizacao.dart';
import 'package:boemix_app/model/singularidade.dart';
import 'package:boemix_app/services/localizacao_service.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'inserir_local.dart';

enum OrderOptions { orderaz, orderza }

class BuscaPorSingularidade extends StatefulWidget {
  final Singularidade singularidade;

  BuscaPorSingularidade(this.singularidade);

  final String title = "Locais por Peculiaridade";

  @override
  BuscaPorSingularidadeState createState() => BuscaPorSingularidadeState();
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

class BuscaPorSingularidadeState extends State<BuscaPorSingularidade> {
  final _debouncer = Debouncer(milliseconds: 500);
  List<Localizacao> locais = List();
  List<Localizacao> locaisFiltrados = List();
  final LocalService services = LocalService();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _preencherListas();
    locais.removeWhere((item) =>
        item.singularidade.nomeSingularidade !=
        this.widget.singularidade.nomeSingularidade);
    locaisFiltrados = locais;
    print(
        locaisFiltrados.contains(this.widget.singularidade.nomeSingularidade));
  }

  void _preencherListas() async {
    await services.retornaTodosLocais().then((response) {
      setState(() {
        locais = response;
        locais.removeWhere((item) =>
            item.singularidade.nomeSingularidade !=
            this.widget.singularidade.nomeSingularidade);
        locaisFiltrados = locais;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.black45,
          title: Text(widget.title),
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
                onSelected: _orderList)
          ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
//          Navigator.push(
//              context, MaterialPageRoute(builder: (context) => LocalPage()));
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
                  locaisFiltrados = locais
                      .where((u) => (u.nomeLocal
                          .toLowerCase()
                          .contains(string.toLowerCase())))
                      .toList();
                });
              });
            },
          ),
          Expanded(
            child: ListView.builder(
                padding: EdgeInsets.all(10.0),
                itemCount: locaisFiltrados.length,
                itemBuilder: (BuildContext context, int index) {
                  return _localCard(context, index);
                }),
          ),
        ],
      ),
    );
  }

  Widget _localCard(BuildContext context, int index) {
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
                                          .length ~/
                                      2) +
                              " Toque para ver mais",
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
        _showOptions(context, index);
      },
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
                              .deleteLocal(locais[index].idLocalizacao)
                              .then((response) {
                            setState(() {
                              if (response) {
                                _scaffoldKey.currentState.showSnackBar(SnackBar(
                                    content: Text("Removido com sucesso")));
                                locais.removeAt(index);
                                Navigator.pop(context);
                              } else {
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

  void _showLocalPage({Localizacao localizacao}) async {
    final editadoLocalizacao = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => InserirLocal(localizacao: localizacao)));
    if (editadoLocalizacao != null) {
      if (localizacao != null) {
        //   await services.updateLocal(editadoLocalizacao);
      } else {
        // await services.postLocal(editadoLocalizacao);
      }
      //  _getAlllocais();
    }
  }

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
        break;
    }
    setState(() {});
  }
}
