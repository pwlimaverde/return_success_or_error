import 'package:return_success_or_error/return_success_or_error.dart';

import '../../../utils/parameters.dart';

final class FeaturesFibonacciPresenter {
  final UsecaseBase<int> _calcFibonacciUsecase;

  FeaturesFibonacciPresenter(
    UsecaseBase<int> calcFibonacciUsecase,
  ) : _calcFibonacciUsecase = calcFibonacciUsecase;

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
