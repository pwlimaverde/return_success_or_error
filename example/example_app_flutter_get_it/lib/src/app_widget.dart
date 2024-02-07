import 'package:example_app_flutter_get_it/src/app_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_getit/flutter_getit.dart';

final class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterGetIt(
      modules: AppModule().routes,
      builder: (context, routes, flutterGetItNavObserver) {
        return MaterialApp(
          navigatorObservers: [flutterGetItNavObserver],
          routes: routes,
          title: 'Example App Flutter Get',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
        );
      },
    );
  }
}
