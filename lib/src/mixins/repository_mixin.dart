import '../core/return_success_or_error.dart';
import '../interfaces/datasource.dart';
import '../interfaces/parameters.dart';

/// Mixin responsible for calling the datasource that loads the data and
/// wrapping the outcome in a [ReturnSuccessOrError].
mixin RepositoryMixin<TypeDatasource> {
  Future<ReturnSuccessOrError<TypeDatasource>> resultDatasource({
    required covariant ParametersReturnResult parameters,
    required Datasource<TypeDatasource> datasource,
  }) async {
    final messageError = parameters.error.message;
    try {
      final result = await datasource(parameters);

      return SuccessReturn(success: result);
    } catch (e) {
      return ErrorReturn(
        error: parameters.error.copyWith(
          message: "$messageError - Cod. 02-1 --- Catch: $e",
        ),
      );
    }
  }
}
