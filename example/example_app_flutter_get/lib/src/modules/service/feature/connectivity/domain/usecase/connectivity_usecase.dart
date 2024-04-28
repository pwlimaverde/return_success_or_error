import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:return_success_or_error/return_success_or_error.dart';

///Usecase with external Datasource call
final class ConnectivityUsecase extends UsecaseBase<Connectivity> {
  final Connectivity connectivity;
  ConnectivityUsecase({required this.connectivity});

  @override
  Future<ReturnSuccessOrError<Connectivity>> call(NoParams parameters) async {
    try {
      return SuccessReturn(success: connectivity);
    } catch (e) {
      return ErrorReturn(
          error: ErrorGeneric(message: "Error ao carregar Connectivity"));
    }
  }
}
