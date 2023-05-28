import '../core/parameters.dart';
import '../core/runtime_milliseconds.dart';
import '../interfaces/datasource.dart';
import '../interfaces/errors.dart';
import 'datasource_mixin.dart';

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

mixin RepositoryMixin<TypeDatasource> {
  Future<({TypeDatasource? result, AppError? error})> returResult({
    required ParametersReturnResult parameters,
    required Datasource<TypeDatasource> datasource,
  }) async {
    final String messageError = parameters.basic.error.message;
    final RuntimeMilliseconds runtime = RuntimeMilliseconds();
    try {
      if (parameters.basic.showRuntimeMilliseconds) {
        runtime.startScore();
      }
      final result = await ResultRepository(datasource: datasource)(
          parameters: parameters);

      if (parameters.basic.showRuntimeMilliseconds) {
        runtime.finishScore();
        print(
            "Execution Time ${parameters.basic.nameFeature}: ${runtime.calculateRuntime()}ms");
      }
      return result;
    } catch (e) {
      return (
        result: null,
        error: parameters.basic.error
          ..message = "$messageError - Cod. 01-1.1 --- Catch: $e",
      );
    }
  }
}
