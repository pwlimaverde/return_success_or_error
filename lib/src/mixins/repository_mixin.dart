import '../core/parameters.dart';
import '../core/return_success_or_error.dart';
import '../interfaces/datasource.dart';

///mixin responsible for calling the ropositore that loads the data from the datasource and measures its execution time
mixin RepositoryMixin<TypeDatasource> {
  Future<ReturnSuccessOrError<TypeDatasource>> resultDatasource({
    required covariant ParametersReturnResult parameters,
    required Datasource<TypeDatasource> datasource,
  }) async {
    final String _messageError = parameters.basic.error.message;
    try {
      final _result = await datasource(parameters);

      return SuccessReturn(success: _result);
    } catch (e) {
      return ErrorReturn(
        error: parameters.basic.error
          ..message = "$_messageError - Cod. 02-1 --- Catch: $e",
      );
    }
  }
}
