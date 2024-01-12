import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo2',
      theme: ThemeData(primarySwatch: Colors.grey),
      routerConfig: Modular.routerConfig,
    ); 
  }
}
