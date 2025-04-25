import 'package:return_success_or_error/return_success_or_error.dart';

import '../../../utils/typedefs.dart';
import 'simple_counter/domain/usecase/two_plus_two_usecase.dart';

final class FeaturesCheckconnectComposer {
  final CCUsecase _checkConnectUsecase;
  final TwoPlusTowUsecase _twoPlusTowUsecase;

  FeaturesCheckconnectComposer({
    required CCUsecase checkConnectUsecase,
    required TwoPlusTowUsecase twoPlusTowUsecase,
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
