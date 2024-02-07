import 'package:flutter/material.dart';
import 'package:rx_notifier/rx_notifier.dart';

import 'fibonacci_state.dart';
import 'widgets/stagger_demo.dart';

final class FibonacciPage extends StatefulWidget {
  const FibonacciPage({super.key});

  @override
  State<FibonacciPage> createState() => _CheckConnectPageState();
}

class _CheckConnectPageState extends State<FibonacciPage> {
  @override
  Widget build(BuildContext context) {
    final fibonacci = context.select(() => fibonacciState.value);
    final load = context.select(() => showProgressState.value);
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
            load
                ? const CircularProgressIndicator()
                : Text(
                    fibonacci != null
                        ? fibonacci.toString()
                        : "Click in Check Fibonacci!",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 400,
              width: 400,
              child: StaggerDemo(
                calc: () {
                  calcFibonacciAction.value = 42;
                },
                calcIsolate: () {
                  calcFibonacciIsolateAction.value = 42;
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
