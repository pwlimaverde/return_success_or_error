import '../core/parameters.dart';
import '../core/return_success_or_error.dart';
import '../interfaces/datasource.dart';

mixin ReturnDatasourcetMixin<R> {
  Future<ReturnSuccessOrError<R>> returnDatasource({
    required ParametersReturnResult parameters,
    required Datasource<R> datasource,
  }) async {
    final String messageError = parameters.error.message;
    try {
      final R result = await datasource(
        parameters: parameters,
      );
      return SuccessReturn<R>(
        success: result,
      );
    } catch (e) {
      return ErrorReturn<R>(
        error: parameters.error
          ..message = "$messageError - Cod. 03-1 --- Catch: $e",
      );
    }
  }
}
