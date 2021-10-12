import '../../return_success_or_error.dart';
import '../core/return_success_or_error_class.dart';

abstract class Repository<R> {
  Future<ReturnSuccessOrError<R>> call({
    required ParametersReturnResult parameters,
  });
}
