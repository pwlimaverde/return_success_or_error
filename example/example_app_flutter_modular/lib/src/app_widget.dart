import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:rx_notifier/rx_notifier.dart';

import 'app_module.dart';

final class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ModularApp(
      module: AppModule(),
      child: RxRoot(
        child: MaterialApp.router(
          title: 'Example App Flutter Modular',
          theme: ThemeData(primarySwatch: Colors.grey),
          routerConfig: Modular.routerConfig,
        ),
      ),
    );
  }
}
