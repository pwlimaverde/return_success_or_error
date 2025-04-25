import 'package:return_success_or_error/return_success_or_error.dart';

import '../../../utils/parameters.dart';
import '../../../utils/typedefs.dart';

final class FeaturesFibonacciComposer {
  final FBUsecase _calcFibonacciUsecase;

  FeaturesFibonacciComposer({
    required FBUsecase calcFibonacciUsecase,
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
