import 'errors.dart';

abstract class ReturnSuccessOrError<R> {
  const ReturnSuccessOrError();
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

class SuccessReturn<R> extends ReturnSuccessOrError<R> {
  final R result;
  const SuccessReturn({required this.result});
}

class ErrorReturn<R> extends ReturnSuccessOrError<R> {
  final AppError error;
  const ErrorReturn({required this.error});
}
