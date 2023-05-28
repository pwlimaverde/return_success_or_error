import '../core/parameters.dart';
import '../core/runtime_milliseconds.dart';
import '../interfaces/datasource.dart';
import '../interfaces/errors.dart';
import 'datasource_mixin.dart';

///class responsible for executing the datasouce function, returning the desired type or an AppErrror.
final class ResultRepository<TypeDatasource>
    with DatasourceMixin<TypeDatasource> {
  final Datasource<TypeDatasource> datasource;

  ResultRepository({
    required this.datasource,
  });

  Future<({TypeDatasource? result, AppError? error})> call({
    required ParametersReturnResult parameters,
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
  Future<({TypeDatasource? result, AppError? error})> resultDatasource({
    required ParametersReturnResult parameters,
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
            "Execution Time ${parameters.basic.nameFeature}: ${_runtime.calculateRuntime()}ms");
      }
      return _result;
    } catch (e) {
      return (
        result: null,
        error: parameters.basic.error
          ..message = "$_messageError - Cod. 01-1.1 --- Catch: $e",
      );
    }
  }
}
