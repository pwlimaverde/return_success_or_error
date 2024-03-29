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
  SuccessReturn({
    required R super.success,
  });

  R get result => _success as R;

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

//Representation of void as a result
final class Unit {
  @override
  String toString() {
    return 'Unit{} - void';
  }
}

//Geter for loading the Unit instance
Unit get unit => Unit();

//Representation of null as a result
final class Nil {
  @override
  String toString() {
    return 'Nil{} - null';
  }
}

//Geter for loading the Nil instance
Nil get nil => Nil();
