import '../core/parameters.dart';
import '../core/return_success_or_error.dart';
import '../mixins/return_usecase_mixin.dart';

abstract class UseCaseImplement<R> with ReturnUsecaseMixin<R> {
  Future<ReturnSuccessOrError<R>> call({
    required ParametersReturnResult parameters,
  });
}
