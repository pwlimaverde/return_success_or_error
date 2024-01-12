import 'package:return_success_or_error/return_success_or_error.dart';

final class CheckConnectPresenter
    extends PresenterBaseCallData<String, ({bool conect, String typeConect})> {
  CheckConnectPresenter(super.usecase);

  @override
  Future<ReturnSuccessOrError<String>> call(
    covariant ParametersReturnResult parameters,
  ) async {
    final result = await usecase(parameters);
    return result;
  }
}
