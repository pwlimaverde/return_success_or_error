import '../core/parameters.dart';
import '../core/return_success_or_error.dart';
import '../interfaces/repository.dart';

mixin ReturnRepositoryMixin<R> {
  Future<ReturnSuccessOrError<R>> returnRepository({
    required ParametersReturnResult parameters,
    required Repository<R> repository,
  }) async {
    final String messageError = parameters.basic.error.message;
    try {
      final result = await repository(
        parameters: parameters,
      );
      return result;
    } catch (e) {
      return ErrorReturn<R>(
        error: parameters.basic.error
          ..message = "$messageError. \n Cod. 02-1 --- Catch: $e",
      );
    }
  }
}
