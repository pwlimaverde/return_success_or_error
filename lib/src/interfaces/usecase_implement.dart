import 'package:return_success_or_error/src/features/return_result/repositories/return_result_repository.dart';
import 'package:return_success_or_error/src/features/return_result/usecases/return_result_usecase.dart';

import '../../return_success_or_error.dart';

abstract class UseCaseImplement<R> {
  Future<ReturnSuccessOrError<R>> call({
    required ParametersReturnResult parameters,
  });

  Future<ReturnSuccessOrError<R>> returnUseCase({
    required ParametersReturnResult parameters,
    required Datasource<R> datasource,
  }) async {
    final String messageError = parameters.error.message;
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
        error: parameters.error
          ..message = "$messageError - Cod. 01-4 --- Catch: $e",
      );
    }
  }
}
