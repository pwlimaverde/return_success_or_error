import 'package:return_success_or_error/return_success_or_error.dart';

import '../model/check_connect_model.dart';

///Usecase with external Datasource call
final class CheckConnectUsecase
    extends UsecaseBaseCallData<String, CheckConnectModel> {
  CheckConnectUsecase(super.datasource);

  @override
  Future<ReturnSuccessOrError<String>> call(NoParams parameters) async {
    final resultDatacource = await resultDatasource(
      parameters: parameters,
      datasource: datasource,
    );

    switch (resultDatacource) {
      case SuccessReturn<CheckConnectModel>():
        if (resultDatacource.result.connect) {
          return SuccessReturn(
            success:
                "You are conect - Type: ${resultDatacource.result.typeConect}",
          );
        } else {
          return ErrorReturn(
              error: parameters.error..message = "You are offline");
        }
      case ErrorReturn<CheckConnectModel>():
        return ErrorReturn(
            error: ErrorGeneric(message: "Error check Connectivity"));
    }
  }
}
