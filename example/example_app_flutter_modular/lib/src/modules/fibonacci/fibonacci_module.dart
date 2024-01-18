import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../utils/routes.dart';

class FibonacciModule extends Module {
  @override
  void routes(r) {
    r.child(Routes.fibonacci.caminho,
        child: (context) => const FibonacciPage());
  }
}

class FibonacciPage extends StatelessWidget {
  const FibonacciPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fibonacci Page')),
      body: const Center(
        child: Text('Fibonacci'),
      ),
    );
  }
}
