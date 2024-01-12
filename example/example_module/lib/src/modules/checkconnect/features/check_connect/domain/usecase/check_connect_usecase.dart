import 'package:return_success_or_error/return_success_or_error.dart';

///Usecase with external Datasource call
final class CheckConnectUsecase
    extends UsecaseBaseCallData<String, ({bool conect, String typeConect})> {
  CheckConnectUsecase(super.datasource);

  @override
  Future<ReturnSuccessOrError<String>> call(NoParams parameters) async {
    final resultDatacource = await resultDatasource(
      parameters: parameters,
      datasource: datasource,
    );

    switch (resultDatacource) {
      case SuccessReturn<({bool conect, String typeConect})>():
        if (resultDatacource.result.conect) {
          return SuccessReturn(
            success:
                "You are conect - Type: ${resultDatacource.result.typeConect}",
          );
        } else {
          return ErrorReturn(
              error: parameters.error..message = "You are offline");
        }
      case ErrorReturn<({bool conect, String typeConect})>():
        return ErrorReturn(
            error: ErrorGeneric(message: "Error check Connectivity"));
    }
  }
}