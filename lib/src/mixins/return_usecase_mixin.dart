import '../core/parameters.dart';
import '../core/return_success_or_error.dart';
import '../interfaces/datasource.dart';
import '../features/return_result/repositories/return_result_repository.dart';
import '../features/return_result/usecases/return_result_usecase.dart';

mixin ReturnUsecaseMixin<R> {
  Future<ReturnSuccessOrError<R>> returnUseCase({
    required ParametersReturnResult parameters,
    required Datasource<R> datasource,
  }) async {
    final String messageError = parameters.basic.error.message;
    try {
      ///Access usecase, and call the repository to call the datasource, handling
      ///the result to return the ReturnSuccessOrError.
      final result = await ReturnResultUsecase<R>(
        repository: ReturnResultRepository<R>(
          datasource: datasource,
        ),
      )(
        parameters: parameters,
      );
      return result;
    } catch (e) {
      return ErrorReturn<R>(
        error: parameters.basic.error
          ..message = "$messageError. \n Cod. 01-1 --- Catch: $e",
      );
    }
  }
}
