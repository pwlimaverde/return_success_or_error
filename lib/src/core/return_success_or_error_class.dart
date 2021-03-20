import 'errors.dart';

///Stores the result of success or failure.
abstract class ReturnSuccessOrError<R> {
  const ReturnSuccessOrError();

  ///Function that returns data stored on success or failure.
  fold({
    required R Function(SuccessReturn<R>) success,
    required AppError Function(ErrorReturn<R>) error,
  }) {
    final _this = this;
    if (_this is SuccessReturn<R>) {
      return success(_this);
    } else {
      return error(_this as ErrorReturn<R>);
    }
  }
}

///Responsible for storing the returned data when successful.
class SuccessReturn<R> extends ReturnSuccessOrError<R> {
  ///Variable stores the result on success.
  final R result;
  const SuccessReturn({required this.result});

  @override
  String toString() {
    return "Success: ${this.result}";
  }
}

///Responsible for storing the returned data when error.
class ErrorReturn<R> extends ReturnSuccessOrError<R> {
  ///Variable stores the result on error.
  final AppError error;
  const ErrorReturn({required this.error});

  @override
  String toString() {
    return "Error: ${this.error}";
  }
}
