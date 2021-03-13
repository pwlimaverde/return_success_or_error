import '../core/errors.dart';
import '../core/return_success_or_error_class.dart';
import 'repository.dart';

abstract class UseCase<R, Parameters> {
  Future<ReturnSuccessOrError<R>> call({required Parameters parameters});

  Future<ReturnSuccessOrError<R>> returnRepository({
    required AppError error,
    required Parameters parameters,
    required Repository<R, Parameters> repository,
  }) async {
    try {
      final result = await repository(parameters: parameters);
      return result;
    } catch (e) {
      return ErrorReturn<R>(
        error: error,
      );
    }
  }
}
