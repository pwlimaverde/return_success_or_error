import '../../return_success_or_error.dart';

abstract class UseCase<R> {
  Future<ReturnSuccessOrError<R>> call({
    required ParametersReturnResult parameters,
  });
}
