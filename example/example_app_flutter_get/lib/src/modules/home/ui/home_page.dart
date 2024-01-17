import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
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
                // IconButton(onPressed: () => Modular.to.pushNamed('/fibonacci/'), icon: const Icon(Icons.calculate)),
                // IconButton(onPressed: () => Modular.to.pushNamed('/checkconnect/'), icon: const Icon(Icons.cast_connected)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
