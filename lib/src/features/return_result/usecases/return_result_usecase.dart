import '../../../abstractions/repository.dart';
import '../../../abstractions/usecase.dart';
import '../../../core/errors.dart';
import '../../../core/parameters.dart';
import '../../../core/return_success_or_error_class.dart';

class ReturnResultUsecase<T> extends UseCase<T, ParametersReturnResult> {
  final Repository<T, ParametersReturnResult> repository;

  ReturnResultUsecase({required this.repository});

  @override
  Future<ReturnSuccessOrError<T>> call({
    required ParametersReturnResult parameters,
  }) async {
    try {
      final result = await returnRepository(
        repository: repository,
        error: ErrorReturnResult(
          message: "${parameters.messageError} Cod.01-1",
        ),
        parameters: parameters,
      );
      return result;
    } catch (e) {
      return ErrorReturn(
        error: ErrorReturnResult(
          message: "${e.toString()} - ${parameters.messageError} Cod.01-2",
        ),
      );
    }
  }
}
