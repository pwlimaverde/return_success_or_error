import '../core/parameters.dart';
import '../core/return_success_or_error.dart';
import '../core/runtime_milliseconds.dart';
import '../interfaces/datasource.dart';
import 'datasource_mixin.dart';

///class responsible for executing the datasouce function, returning the desired type or an AppErrror.
final class ResultRepository<TypeDatasource>
    with DatasourceMixin<TypeDatasource> {
  final Datasource<TypeDatasource> datasource;

  ResultRepository({
    required this.datasource,
  });

  Future<ReturnSuccessOrError<TypeDatasource>> call({
    required covariant ParametersReturnResult parameters,
  }) async {
    final _result = await returnDatasource(
      parameters: parameters,
      datasource: datasource,
    );
    return _result;
  }
}

///mixin responsible for calling the ropositore that loads the data from the datasource and measures its execution time
mixin RepositoryMixin<TypeDatasource> {
  Future<ReturnSuccessOrError<TypeDatasource>> resultDatasource({
    required covariant ParametersReturnResult parameters,
    required Datasource<TypeDatasource> datasource,
  }) async {
    final String _messageError = parameters.basic.error.message;
    final RuntimeMilliseconds _runtime = RuntimeMilliseconds();
    try {
      if (parameters.basic.showRuntimeMilliseconds) {
        _runtime.startScore();
      }

      final _result = await ResultRepository(datasource: datasource)(
          parameters: parameters);

      if (parameters.basic.showRuntimeMilliseconds) {
        _runtime.finishScore();
        print(
            "Execution Time ${this.toString().split("Instance of ")[1].replaceAll("'", "")}: ${_runtime.calculateRuntime()}ms");
      }
      return _result;
    } catch (e) {
      return ErrorReturn(
        error: parameters.basic.error
          ..message = "$_messageError - Cod. 02-1 --- Catch: $e",
      );
    }
  }
}
