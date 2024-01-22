import 'package:get/get.dart';

import 'package:return_success_or_error/return_success_or_error.dart';

import '../../../utils/parameters.dart';

class FibonacciController extends GetxController {
  final UsecaseBase<int> calcFibonacciUsecaseUsecase;
  FibonacciController(
    this.calcFibonacciUsecaseUsecase,
  );

  final _showProgress = false.obs;
  set showProgress(value) => _showProgress.value = value;
  get showProgress => _showProgress.value;

  final _fibonacciState = RxnInt(null);
  set fibonacciState(value) => _fibonacciState.value = value;
  get fibonacciState => _fibonacciState.value;

  void calcFibonacci({required number}) async {
    await _load(true);

    final status = await calcFibonacciUsecaseUsecase(
      ParametrosFibonacci(
        num: number,
        error: ErrorGeneric(
          message: "Erro al calcular fibonacci!",
        ),
      ),
    );
    switch (status) {
      case SuccessReturn<int>():
        _fibonacciState(status.result);
      case ErrorReturn<int>():
        _fibonacciState(null);
    }

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
