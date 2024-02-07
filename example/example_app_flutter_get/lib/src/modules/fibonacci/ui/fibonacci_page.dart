import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'fibonacci_controller.dart';
import 'widgets/stagger_demo.dart';

final class FibonacciPage extends GetView<FibonacciController> {
  const FibonacciPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Fibonacci"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Fibonacci calc result:',
            ),
            const SizedBox(
              height: 10,
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
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 400,
              width: 400,
              child: StaggerDemo(
                calc: () {
                  controller.calcFibonacci(42);
                },
                calcIsolate: () {
                  controller.calcFibonacciIsolate(42);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
