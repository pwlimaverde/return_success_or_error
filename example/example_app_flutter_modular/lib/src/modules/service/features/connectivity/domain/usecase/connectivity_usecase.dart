import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:return_success_or_error/return_success_or_error.dart';

///Usecase with external Datasource call
final class ConnectivityUsecase extends UsecaseBase<Connectivity> {

  @override
  Future<ReturnSuccessOrError<Connectivity>> call(NoParams parameters) async {
    try {
      final connectivity = Connectivity();
      return SuccessReturn(success: connectivity);
    } catch (e) {
      return ErrorReturn(
          error: ErrorGeneric(message: "Error ao carregar Connectivity"));
    }
  }
}

typedef ConnectUsecase = UsecaseBase<Connectivity>;
