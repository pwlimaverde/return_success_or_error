import 'package:return_success_or_error/src/features/return_result/repositories/return_result_repository.dart';
import 'package:return_success_or_error/src/features/return_result/usecases/return_result_usecase.dart';
import 'package:return_success_or_error/src/mixins/return_usecase_mixin.dart';

import '../../return_success_or_error.dart';

abstract class UseCaseImplement<R> with ReturnUsecaseMixin<R> {
  Future<ReturnSuccessOrError<R>> call({
    required ParametersReturnResult parameters,
  });
}
