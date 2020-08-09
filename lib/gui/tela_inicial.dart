import 'package:boemix_app/gui/busca_update.dart';
import 'package:flutter/material.dart';

import 'busca.dart';

class TelaInicial extends StatelessWidget {
  Widget _menu(BuildContext context) {
    return Stack(
      alignment: Alignment(0, 0),
      children: <Widget>[
        Image.asset(
          'lib/images/logo.jpeg',
          fit: BoxFit.fill,
          height: 10000.0,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            SizedBox(
              width: double.infinity,
              child: RaisedButton(
                child: Text(
                  "Nome",
                  style: TextStyle(fontSize: 30.0, color: Colors.black87),
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BuscaUpdate("Nome")));
//                  Navigator.push(context,
//                      MaterialPageRoute(builder: (context) => Busca("Nome")));
                },
              ),
            ),
            //Padding(
            SizedBox(
              width: double.infinity,
              child: RaisedButton(
                child: Text(
                  "Peculiaridade",
                  style: TextStyle(fontSize: 30.0, color: Colors.black87),
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BuscaUpdate("Peculiaridade")));
                },
              ),
            ),
            SizedBox(height: 70)
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black45,
          centerTitle: true,
          title: Text("Boêmixs"),
        ),
        body: _menu(context));
  }
}
