import 'package:return_success_or_error/return_success_or_error.dart';

import 'check_connect/domain/model/check_connect_model.dart';

final class FeaturesCheckconnectPresenter {
  final UsecaseBaseCallData<String, CheckConnecModel> _checkConnectUsecase;
  final UsecaseBase<int> _twoPlusTowUsecase;

  FeaturesCheckconnectPresenter({
    required UsecaseBaseCallData<String, CheckConnecModel> checkConnectUsecase,
    required UsecaseBase<int> twoPlusTowUsecase,
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
