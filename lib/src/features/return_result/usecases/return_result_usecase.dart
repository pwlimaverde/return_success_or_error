import '../../../core/runtime_milliseconds.dart';
import '../../../mixins/return_repository_mixin.dart';
import '../../../core/parameters.dart';
import '../../../core/return_success_or_error.dart';
import '../../../interfaces/repository.dart';
import '../../../interfaces/usecase.dart';

class ReturnResultUsecase<T>
    with ReturnRepositoryMixin<T>
    implements UseCase<T> {
  final Repository<T> repository;

  ReturnResultUsecase({
    required this.repository,
  });

  @override
  Future<ReturnSuccessOrError<T>> call({
    required ParametersReturnResult parameters,
  }) async {
    final String messageError = parameters.basic.error.message;
    final RuntimeMilliseconds runtime = RuntimeMilliseconds();
    try {
      if (parameters.basic.showRuntimeMilliseconds) {
        runtime.startScore();
      }
      final result = await returnRepository(
        parameters: parameters,
        repository: repository,
      );
      if (parameters.basic.showRuntimeMilliseconds) {
        runtime.finishScore();
        print(
            "Execution Time ${parameters.basic.nameFeature}: ${runtime.calculateRuntime()}ms");
      }
      return result;
    } catch (e) {
      return ErrorReturn<T>(
        error: parameters.basic.error
          ..message = "$messageError - Cod. 01-1.1 --- Catch: $e",
      );
    }
  }
}
