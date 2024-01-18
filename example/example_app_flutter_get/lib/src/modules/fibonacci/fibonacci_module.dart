import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/module.dart';
import '../../utils/routes.dart';

class FibonacciModule extends Module {
  @override
  List<GetPage> routes = [
    GetPage(
      name: Routes.fibonacci.caminho,
      page: () => const FibonacciPage(),
    )
  ];
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
