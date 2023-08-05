import '../../return_success_or_error.dart';

sealed class ReturnSuccessOrError<R> {
  final AppError? _error;
  final R? _success;
  const ReturnSuccessOrError({
    R? success,
    AppError? error,
  })  : _success = success,
        _error = error;
}

///Responsible for storing the returned data when successful.
final class SuccessReturn<R> extends ReturnSuccessOrError<R> {
  const SuccessReturn({
    required R super.success,
  });

  R get result => _success!;

  @override
  String toString() {
    return "Success: ${this.result}";
  }
}

///Responsible for storing the returned data when error.
final class ErrorReturn<R> extends ReturnSuccessOrError<R> {
  const ErrorReturn({
    required AppError super.error,
  });

  AppError get result => _error!;

  @override
  String toString() {
    return "Error: ${this.result}";
  }
}
