import '../core/parameters.dart';
import '../core/runtime_milliseconds.dart';
import '../interfaces/datasource.dart';
import '../features/return_result/repositories/return_result_repository.dart';
import '../interfaces/errors.dart';

mixin ReturnUsecaseMixin<TypeDatasource> {
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
      final result = await ReturnResultRepository(datasource: datasource)(
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
    // final String messageError = parameters.basic.error.message;
    // try {
    //   ///Access usecase, and call the repository to call the datasource, handling
    //   ///the result to return the ReturnSuccessOrError.
    //   final result = await ReturnResultUsecase<R>(
    //     repository: ReturnResultRepository<R>(
    //       datasource: datasource,
    //     ),
    //   )(
    //     parameters: parameters,
    //   );
    //   return result;
    // } catch (e) {
    //   return ErrorReturn(
    //     error: parameters.basic.error
    //       ..message = "$messageError. \n Cod. 01-1 --- Catch: $e",
    //   );
    // }
  }
}
