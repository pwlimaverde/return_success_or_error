import 'package:return_success_or_error/return_success_or_error.dart';
import 'check_connect/domain/usecase/check_connect_usecase.dart';
import 'simple_counter/domain/usecase/two_plus_two_usecase.dart';

final class FeaturesCheckconnectComposer {
  final CheckConnect _checkConnectUsecase;
  final TwoPlusTow _twoPlusTowUsecase;

  FeaturesCheckconnectComposer({
    required CheckConnect checkConnectUsecase,
    required TwoPlusTow twoPlusTowUsecase,
  })  : _checkConnectUsecase = checkConnectUsecase,
        _twoPlusTowUsecase = twoPlusTowUsecase;

  Future<String?> checkConnect(NoParams params) async {
    final data = await _checkConnectUsecase(params);
    switch (data) {
      case SuccessReturn<String>():
        return data.result;
      case ErrorReturn<String>():
        return data.result.message;
    }
  }

  Future<int?> twoPlusTow(NoParams params) async {
    final data = await _twoPlusTowUsecase(params);
    switch (data) {
      case SuccessReturn<int>():
        return data.result;
      case ErrorReturn<int>():
        return 0;
    }
  }
}
