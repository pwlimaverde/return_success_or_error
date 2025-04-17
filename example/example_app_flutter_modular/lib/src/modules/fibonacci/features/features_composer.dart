import 'package:return_success_or_error/return_success_or_error.dart';

import '../../../utils/parameters.dart';
import 'calc_fibonacci/domain/calc_fibonacci_usecase.dart';
import 'feature_hub.dart';

final class FeaturesComposer implements Composer {
  @override
  late FeatureHub hub;

  final CalcFibonacci _calcFibonacciUsecase;

  FeaturesComposer({
    required FeatureHub featureHub,
    required CalcFibonacci calcFibonacciUsecase,
  }) : _calcFibonacciUsecase = calcFibonacciUsecase,
       hub = featureHub;

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
