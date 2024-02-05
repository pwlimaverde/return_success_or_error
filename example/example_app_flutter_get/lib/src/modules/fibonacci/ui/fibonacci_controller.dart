import 'package:get/get.dart';

import 'package:return_success_or_error/return_success_or_error.dart';

import '../../../utils/parameters.dart';
import '../feature/features_fibonacci_presenter.dart';

class FibonacciController extends GetxController {
  final FeaturesFibonacciPresenter featuresFibonacciPresenter;

  FibonacciController({
    required this.featuresFibonacciPresenter,
  });

  final _showProgress = false.obs;
  set showProgress(value) => _showProgress.value = value;
  get showProgress => _showProgress.value;

  final _fibonacciState = RxnInt(null);
  set fibonacciState(value) => _fibonacciState.value = value;
  get fibonacciState => _fibonacciState.value;

  void calcFibonacci(int number) async {
    await _load(true);

    final status = await featuresFibonacciPresenter.calcFibonacci(
      ParametrosFibonacci(
        num: number,
        error: ErrorGeneric(
          message: "Erro al calcular fibonacci!",
        ),
      ),
    );

    _fibonacciState(status);

    await _load(false);
  }

  void calcFibonacciIsolate(int number) async {
    await _load(true);

    final status = await featuresFibonacciPresenter.calcFibonacciIsolate(
      ParametrosFibonacci(
        num: number,
        error: ErrorGeneric(
          message: "Erro al calcular fibonacci!",
        ),
      ),
    );

    _fibonacciState(status);

    await _load(false);
  }

  Future<void> _load(bool load) async {
    if (load) {
      _showProgress(true);
      await Future.delayed(const Duration(seconds: 1));
    } else {
      _showProgress(false);
    }
  }
}
