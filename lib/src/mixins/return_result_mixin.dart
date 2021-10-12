import '../interfaces/repository.dart';
import '../../return_success_or_error.dart';

mixin ReturnResultMixin<R> {
  Future<ReturnSuccessOrError<R>> returnRepository({
    required ParametersReturnResult parameters,
    required Repository<R> repository,
  }) async {
    final String messageError = parameters.error.message;
    try {
      final result = await repository(
        parameters: parameters,
      );
      return result;
    } catch (e) {
      return ErrorReturn<R>(
        error: parameters.error
          ..message = "$messageError - Cod. 01-3 --- Catch: $e",
      );
    }
  }

  Future<ReturnSuccessOrError<R>> returnDatasource({
    required ParametersReturnResult parameters,
    required Datasource<R> datasource,
  }) async {
    try {
      final R result = await datasource(
        parameters: parameters,
      );
      return SuccessReturn<R>(result: result);
    } catch (e) {
      return ErrorReturn<R>(
        error: parameters.error..message = e.toString(),
      );
    }
  }
}
