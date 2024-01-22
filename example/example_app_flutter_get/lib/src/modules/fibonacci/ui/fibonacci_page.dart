import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'fibonacci_controller.dart';

class FibonacciPage extends GetView<FibonacciController> {
  const FibonacciPage({super.key});

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
              'Fibonacci calc result:',
            ),
            Obx(
              () {
                if (controller.showProgress) {
                  return const CircularProgressIndicator();
                } else {
                  return Text(
                    controller.fibonacciState != null
                        ? controller.fibonacciState.toString()
                        : "Click in Check Fibonacci!",
                    style: Theme.of(context).textTheme.headlineMedium,
                  );
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.calcFibonacci(number: 42);
        },
        tooltip: 'Calc Fibonacci',
        child: const Icon(Icons.calculate_rounded),
      ),
    );
  }
}
