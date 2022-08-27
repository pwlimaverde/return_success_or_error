import '../core/parameters.dart';
import '../core/return_success_or_error.dart';

abstract class Repository<R> {
  Future<ReturnSuccessOrError<R>> call({
    required ParametersReturnResult parameters,
  });
}
