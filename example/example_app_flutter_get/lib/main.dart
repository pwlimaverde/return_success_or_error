import 'package:example_app_flutter_get/src/modules/checkconnect/check_connect_module.dart';
import 'package:example_app_flutter_get/src/modules/fibonacci/fibonacci_module.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'src/modules/home/home_module.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Example App Flutter Get',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      getPages: [
        ...HomeModule().routers,
        ...FibonacciModule().routers,
        ...CheckConnectModule().routers,
      ],
    );
  }
}
