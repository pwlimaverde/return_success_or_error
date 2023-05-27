import '../core/parameters.dart';
import 'errors.dart';

abstract interface class ResultSuccessOrError<R> {
  Future<({R? result, AppError? error})> call({
    required ParametersReturnResult parameters,
  });
}
