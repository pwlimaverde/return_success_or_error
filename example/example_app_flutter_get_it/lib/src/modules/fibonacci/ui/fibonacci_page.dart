import 'package:flutter/material.dart';
import 'package:flutter_getit/flutter_getit.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'fibonacci_controller.dart';
import 'widgets/stagger_demo.dart';

final class FibonacciPage extends StatefulWidget {
  const FibonacciPage({super.key});

  @override
  State<FibonacciPage> createState() => _CheckConnectPageState();
}

class _CheckConnectPageState extends State<FibonacciPage> {
  final controller = Injector.get<FibonacciController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Fibonacci"),
      ),
      body: Watch(
        (context) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Fibonacci calc result:',
              ),
              const SizedBox(
                height: 10,
              ),
              controller.showProgress
                  ? const CircularProgressIndicator()
                  : Text(
                      controller.fibonacciState != null
                          ? controller.fibonacciState.toString()
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
      ),
    );
  }
}
