import 'package:return_success_or_error/return_success_or_error.dart';
import 'package:rx_notifier/rx_notifier.dart';

import '../../../utils/parameters.dart';
import '../features/features_composer.dart';
import 'fibonacci_state.dart';

final class FibonacciReducer extends RxReducer {
  final FeaturesComposer featuresComposer;
  FibonacciReducer(this.featuresComposer) {
    on(() => [calcFibonacciAction], _calcFibonacci);
    on(() => [calcFibonacciIsolateAction], _calcFibonacciIsolate);
  }

  void _calcFibonacci() async {
    final num = calcFibonacciAction.value;
    if (num != null) {
      await _load(true);

      final status = featuresComposer.calcFibonacci(
        ParametrosFibonacci(
          num: num,
          error: ErrorGeneric(
            message: "Erro al calcular fibonacci!",
          ),
        ),
      );

      fibonacciState.value = await status;

      await _load(false);
    }
  }

  void _calcFibonacciIsolate() async {
    final num = calcFibonacciAction.value;
    if (num != null) {
      await _load(true);

      final status = featuresComposer.calcFibonacciIsolate(
        ParametrosFibonacci(
          num: num,
          error: ErrorGeneric(
            message: "Erro al calcular fibonacci!",
          ),
        ),
      );

      fibonacciState.value = await status;

      await _load(false);
    }
  }

  Future<void> _load(bool load) async {
    if (load) {
      showProgressState.value = true;
      await Future.delayed(const Duration(seconds: 1));
    } else {
      showProgressState.value = false;
    }
  }

  @override
  void dispose() {
    fibonacciState.value = null;
    showProgressState.value = false;
    super.dispose();
  }
}
