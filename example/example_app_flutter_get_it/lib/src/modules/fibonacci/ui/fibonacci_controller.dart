import 'package:return_success_or_error/return_success_or_error.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../../utils/parameters.dart';
import '../feature/features_fibonacci_composer.dart';

final class FibonacciController {
  final FeaturesFibonacciComposer featuresFibonacciComposer;

  FibonacciController({
    required this.featuresFibonacciComposer,
  });

  final _showProgress = signal<bool?>(false);
  get showProgress => _showProgress.value;

  final _fibonacciState = signal<int?>(null);
  get fibonacciState => _fibonacciState.value;

  void calcFibonacci(int number) async {
    await _load(true);

    final status = await featuresFibonacciComposer.calcFibonacci(
      ParametrosFibonacci(
        num: number,
        error: ErrorGeneric(
          message: "Erro al calcular fibonacci!",
        ),
      ),
    );

    _fibonacciState.value = status;

    await _load(false);
  }

  void calcFibonacciIsolate(int number) async {
    await _load(true);

    final status = await featuresFibonacciComposer.calcFibonacciIsolate(
      ParametrosFibonacci(
        num: number,
        error: ErrorGeneric(
          message: "Erro al calcular fibonacci!",
        ),
      ),
    );

    _fibonacciState.value = status;

    await _load(false);
  }

  Future<void> _load(bool load) async {
    if (load) {
      _showProgress.value = true;
      await Future.delayed(const Duration(seconds: 1));
    } else {
      _showProgress.value = false;
    }
  }
}
