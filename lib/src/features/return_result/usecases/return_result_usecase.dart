import '../../../../return_success_or_error.dart';
import '../../../core/parameters.dart';
import '../../../core/return_success_or_error_class.dart';
import '../../../interfaces/repository.dart';
import '../../../interfaces/usecase.dart';

class ReturnResultUsecase<T> extends UseCase<T> {
  final Repository<T> repository;

  ReturnResultUsecase({
    required this.repository,
  });

  @override
  Future<ReturnSuccessOrError<T>> call({
    required ParametersReturnResult parameters,
  }) async {
    final String messageError = parameters.error.message;
    final RuntimeMilliseconds runtime = RuntimeMilliseconds();
    try {
      if (parameters.showRuntimeMilliseconds) {
        runtime.startScore();
      }
      final result = await returnRepository(
        parameters: parameters,
        repository: repository,
      );
      if (parameters.showRuntimeMilliseconds) {
        runtime.finishScore();
        print(
            "Execution Time ${parameters.nameFeature}: ${runtime.calculateRuntime()}ms");
      }
      return result;
    } catch (e) {
      return ErrorReturn(
        error: parameters.error
          ..message = "$messageError - Cod. 01-1 --- Catch: $e",
      );
    }
  }
}
