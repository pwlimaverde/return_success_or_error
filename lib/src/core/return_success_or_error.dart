import '../interfaces/errors.dart';

///enum for success or error status setting.
enum StatusResult {
  success,
  error;
}

///Stores the result of success or failure.
abstract base class ReturnSuccessOrError<R> {
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

  StatusResult get status => StatusResult.success;
  R get result => _success!;

  @override
  String toString() {
    return "Success: ${this.result}";
  }
}

///Responsible for storing the returned data when error.
final class ErrorReturn extends ReturnSuccessOrError {
  const ErrorReturn({
    required AppError super.error,
  });

  StatusResult get status => StatusResult.error;
  AppError get result => _error!;

  @override
  String toString() {
    return "Error: ${this.result}";
  }
}
