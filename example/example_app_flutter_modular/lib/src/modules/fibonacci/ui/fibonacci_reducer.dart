import 'package:flutter_modular/flutter_modular.dart';
import 'package:return_success_or_error/return_success_or_error.dart';
import 'package:rx_notifier/rx_notifier.dart';

import '../../../utils/parameters.dart';
import '../feature/features_fibonacci_presenter.dart';
import 'fibonacci_state.dart';

class FibonacciReducer extends RxReducer {
  final UsecaseBase<int> calcFibonacciUsecase;
  FibonacciReducer(this.calcFibonacciUsecase) {
    on(() => [calcFibonacciAction], _calcFibonacci);
    on(() => [calcFibonacciIsolateAction], _calcFibonacciIsolate);
  }

  void _calcFibonacci() async {
    final num = calcFibonacciAction.value;
    if (num != null) {
      await _load(true);

      final status = Modular.get<FeaturesFibonacciPresenter>().calcFibonacci(
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

      final status =
          Modular.get<FeaturesFibonacciPresenter>().calcFibonacciIsolate(
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
