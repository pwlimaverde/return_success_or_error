import 'package:return_success_or_error/return_success_or_error.dart';

import '../../../utils/parameters.dart';
import 'calc_fibonacci/domain/calc_fibonacci_usecase.dart';

final class FeaturesFibonacciPresenter {
  final CalcFibonacci _calcFibonacciUsecase;

  FeaturesFibonacciPresenter({
    required CalcFibonacci calcFibonacciUsecase,
  }) : _calcFibonacciUsecase = calcFibonacciUsecase;

  Future<int?> calcFibonacci(ParametrosFibonacci params) async {
    final data = await _calcFibonacciUsecase(params);
    switch (data) {
      case SuccessReturn<int>():
        return data.result;
      case ErrorReturn<int>():
        return null;
    }
  }

  Future<int?> calcFibonacciIsolate(ParametrosFibonacci params) async {
    final data = await _calcFibonacciUsecase.callIsolate(params);
    switch (data) {
      case SuccessReturn<int>():
        return data.result;
      case ErrorReturn<int>():
        return null;
    }
  }
}
