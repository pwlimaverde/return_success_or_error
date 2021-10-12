import '../core/parameters.dart';
import '../core/return_success_or_error_class.dart';
import '../interfaces/datasource.dart';

mixin ReturnDatasourcetMixin<R> {
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
