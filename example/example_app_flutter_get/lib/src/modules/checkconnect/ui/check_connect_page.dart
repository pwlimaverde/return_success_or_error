import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'check_connect_controller.dart';

class CheckConnectPage extends GetView<CheckConnectController> {
  const CheckConnectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Check Connect"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Connection query result:',
            ),
            Obx(() => Text(
                  controller.checarConeccaoState ?? "Click in Check conect!",
                  style: Theme.of(context).textTheme.headlineMedium,
                )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.checkConnect();
        },
        tooltip: 'Check conect',
        child: const Icon(Icons.analytics),
      ),
    );
  }
}
