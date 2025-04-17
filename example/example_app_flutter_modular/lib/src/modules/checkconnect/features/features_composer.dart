
import 'package:return_success_or_error/return_success_or_error.dart';
import 'check_connect/domain/usecase/check_connect_usecase.dart';
import 'feature_hub.dart';
import 'simple_counter/domain/usecase/two_plus_two_usecase.dart';

final class FeaturesComposer implements Composer {
  @override
  late FeatureHub hub;
  final CheckConnectUsecase _checkConnectUsecase;
  final TwoPlusTow _twoPlusTowUsecase;

  FeaturesComposer({
    required FeatureHub featureHub,
    required CheckConnectUsecase checkConnectUsecase,
    required TwoPlusTow twoPlusTowUsecase,
  })  : _checkConnectUsecase = checkConnectUsecase,
        hub = featureHub,
        _twoPlusTowUsecase = twoPlusTowUsecase;

  Future<String> checkConnect() async {
    final data = await _checkConnectUsecase(NoParams());
    switch (data) {
      case SuccessReturn<String>():
        return data.result;
      case ErrorReturn<String>():
        return data.result.message;
    }
  }

  Future<int> twoPlusTow() async {
    final data = await _twoPlusTowUsecase(NoParams());
    switch (data) {
      case SuccessReturn<int>():
        return data.result;
      case ErrorReturn<int>():
        return 0;
    }
  }

  
}
