import 'package:return_success_or_error/src/abstractions/repository.dart';

import '../../return_success_or_error.dart';

abstract class UseCase<R> {
  Future<ReturnSuccessOrError<R>> call({
    required ParametersReturnResult parameters,
  });

  Future<ReturnSuccessOrError<R>> returnRepository({
    required ParametersReturnResult parameters,
    required Repository<R> repository,
  }) async {
    final String messageError = parameters.error.message;
    try {
      final result = await repository(parameters: parameters);
      return result;
    } catch (e) {
      return ErrorReturn<R>(
        error: parameters.error
          ..message = "$messageError - Cod. 01-3 --- Catch: $e",
      );
    }
  }
}
