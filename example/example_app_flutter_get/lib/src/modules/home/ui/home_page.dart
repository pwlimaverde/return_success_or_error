import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/routes.dart';

final class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: Center(
        child: Column(
          children: [
            const Center(
              child: Text('This is initial page'),
            ),
            const SizedBox(
              width: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    onPressed: () => Get.toNamed(Routes.fibonacci.caminho),
                    icon: const Icon(Icons.calculate)),
                IconButton(
                    onPressed: () => Get.toNamed(Routes.checkconnect.caminho),
                    icon: const Icon(Icons.cast_connected)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
