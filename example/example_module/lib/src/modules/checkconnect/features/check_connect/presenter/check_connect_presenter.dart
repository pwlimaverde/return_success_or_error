import 'package:return_success_or_error/return_success_or_error.dart';

import '../domain/model/check_connect_model.dart';

final class CheckConnectPresenter
    extends PresenterBaseCallData<String, CheckConnecModel> {
  CheckConnectPresenter(super.usecase);

  @override
  Future<ReturnSuccessOrError<String>> call(
    covariant ParametersReturnResult parameters,
  ) async {
    final result = await usecase(parameters);

    return result;
  }
}
