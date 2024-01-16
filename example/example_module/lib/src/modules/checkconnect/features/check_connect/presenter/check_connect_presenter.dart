import 'package:flutter_modular/flutter_modular.dart';
import 'package:return_success_or_error/return_success_or_error.dart';

final class CheckConnectPresenter extends PresenterBase<String> {
  @override
  Future<ReturnSuccessOrError<String>> call(
    covariant ParametersReturnResult parameters,
  ) async {
    final checkConnectPresenter = Modular.get<
        UsecaseBaseCallData<String, ({bool conect, String typeConect})>>();
    final result = await checkConnectPresenter(parameters);

    return result;
  }
}
