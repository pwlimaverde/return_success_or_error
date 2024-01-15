import 'package:flutter_modular/flutter_modular.dart';
import 'package:return_success_or_error/return_success_or_error.dart';

final checkConnectPresenter = Modular.get<
    UsecaseBaseCallData<String, ({bool conect, String typeConect})>>();

final class CheckConnectPresenter
    extends PresenterBaseCallData<String, ({bool conect, String typeConect})> {
  CheckConnectPresenter(super.usecase);

  @override
  Future<ReturnSuccessOrError<String>> call(
    covariant ParametersReturnResult parameters,
  ) async {
    final teste = checkConnectPresenter(NoParams());
    final result = await usecase(parameters);
    return result;
  }
}
