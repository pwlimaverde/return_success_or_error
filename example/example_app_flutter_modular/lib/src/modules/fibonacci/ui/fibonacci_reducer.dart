import 'package:return_success_or_error/return_success_or_error.dart';
import 'package:rx_notifier/rx_notifier.dart';

import '../../../utils/parameters.dart';
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

      final status = await calcFibonacciUsecase(
        ParametrosFibonacci(
          num: num,
          error: ErrorGeneric(
            message: "Erro al calcular fibonacci!",
          ),
        ),
      );
      switch (status) {
        case SuccessReturn<int>():
          fibonacciState.value = status.result;

        case ErrorReturn<int>():
          fibonacciState.value = null;
      }

      await _load(false);
    }
  }

  void _calcFibonacciIsolate() async {
    final num = calcFibonacciIsolateAction.value;
    if (num != null) {
      await _load(true);

      final status = await calcFibonacciUsecase.callIsolate(
        ParametrosFibonacci(
          num: num,
          error: ErrorGeneric(
            message: "Erro al calcular fibonacci!",
          ),
        ),
      );
      switch (status) {
        case SuccessReturn<int>():
          fibonacciState.value = status.result;

        case ErrorReturn<int>():
          fibonacciState.value = null;
      }

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
