import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tela_inicial.dart';
class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Container(
          width: 600,
          height: 600,
          child: Image.asset("lib/images/Logo_logotipo_unipampa_cor.jpg"),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    Future.delayed(Duration(seconds: 5)).then((_) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TelaInicial()));
    });
  }
}
