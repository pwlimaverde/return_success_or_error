import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

import '../../utils/module.dart';
import '../../utils/routes.dart';

class CheckConnectModule extends Module {
  @override
  List<GetPage> routers = [
    GetPage(
      name: Routes.checkconnect.caminho,
      page: () => const CheckConnectPage(),
      bindings: const [],
    )
  ];
}

class CheckConnectPage extends StatelessWidget {
  const CheckConnectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CheckConnectPage Page')),
      body: const Center(
        child: Text('CheckConnect Page'),
      ),
    );
  }
}
