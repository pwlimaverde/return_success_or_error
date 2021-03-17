import '../../../abstractions/repository.dart';
import '../../../abstractions/usecase.dart';
import '../../../core/parameters.dart';
import '../../../core/return_success_or_error_class.dart';

class ReturnResultUsecase<T> extends UseCase<T> {
  final Repository<T> repository;

  ReturnResultUsecase({required this.repository});

  @override
  Future<ReturnSuccessOrError<T>> call({
    required ParametersReturnResult parameters,
  }) async {
    final String messageError = parameters.error.message;
    try {
      final result = await returnRepository(
        repository: repository,
        parameters: parameters,
      );
      return result;
    } catch (e) {
      return ErrorReturn(
        error: parameters.error
          ..message = "$messageError - Cod. 01-1 --- Catch: $e",
      );
    }
  }
}
