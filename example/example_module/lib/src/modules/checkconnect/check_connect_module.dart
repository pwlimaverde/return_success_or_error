import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class CheckConnectModule extends Module {
  @override
  void binds(i) {}

  @override
  void routes(r) {
    r.child('/', child: (context) => const CheckConnectPage());
  }
}

class CheckConnectPage extends StatelessWidget {
  const CheckConnectPage({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('CheckConnect Page')),
      body: const Center(
        child: Text('CheckConnect'),
      ),
    );
  }
}