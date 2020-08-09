import 'dart:async';
import 'dart:convert';

import 'package:boemix_app/model/localizacao.dart';
import 'package:boemix_app/model/singularidade.dart';
import 'package:boemix_app/services/localizacao_service.dart';
import 'package:boemix_app/services/singularidade_service.dart';
import 'package:flutter/material.dart';

enum OrderOptions { orderaz, orderza }

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

class BuscaUpdate extends StatefulWidget {
  final String opcao;

  BuscaUpdate(this.opcao);

  @override
  _BuscaUpdateState createState() => _BuscaUpdateState();
}

class _BuscaUpdateState extends State<BuscaUpdate> {
  final _serviceLocal = LocalService();
  final _serviceSingular = SingularidadeService();
  final _debouncer = Debouncer(milliseconds: 500);
  List<Localizacao> _locais = List();
  List<Localizacao> _locaisFiltrados = List();
  List<Singularidade> _listaSingularidade, _singularidadeFiltrada = List();

  final SingularidadeService _singularidadeService = SingularidadeService();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

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
//                onSelected: this.widget.opcao.contains("Nome")
//                    ? _orderList
//                    : orderSingularidade)
            )
          ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
//          Navigator.push(
//              context, MaterialPageRoute(builder: (context) => InserirLocal()));
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
                    _locaisFiltrados = _locais
                        .where((u) => (u.nomeLocal
                            .toLowerCase()
                            .contains(string.toLowerCase())))
                        .toList();
                  } else {
                    _singularidadeFiltrada = _listaSingularidade
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
                    ? _locaisFiltrados.length
                    : _singularidadeFiltrada.length,
                itemBuilder: (BuildContext context, int index) {
                  return _cartaoOpcoes(context, index, this.widget.opcao);
                }),
          ),
        ],
      ),
    );
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
                        child: _locaisFiltrados[index].imagem != null
                            ? Image.memory(
                          (base64Decode(_locaisFiltrados[index].imagem)),
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
                          _locaisFiltrados[index].nomeLocal == null
                              ? "Sem Nome"
                              : _locaisFiltrados[index].nomeLocal,
                          style: TextStyle(
                              fontSize: 22.0, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _locaisFiltrados[index].descricaoLocal == null
                              ? "Sem descrição"
                              : _locaisFiltrados[index].descricaoLocal.substring(
                              0,
                              _locaisFiltrados[index]
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
     //       _showOptions(context, index);
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
                          _singularidadeFiltrada[index].nomeSingularidade ?? "",
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
            //_showOptionsPeculiar(
              //  context, index, singularidadeFiltrada[index].nomeSingularidade);
          },
        );
        break;
    }
  }

  @override
  void initState() {

    preencherLista(this.widget.opcao);
    super.initState();
  }

  Widget preencherLista(String op) {
    if (op.contains("Nome")) {
      print("entrou em nome");
      return Center(
        child: FutureBuilder<List<Localizacao>>(
          future: _serviceLocal.retornaTodosLocais(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              print("DADOS ${snapshot.data}");
              return Container(child: Text("DADOS ${snapshot.data[0]}"));
            } else {
              print("Não retornou porra nenhuma");
              return Center(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
        ),
      );
    }
  }
}
