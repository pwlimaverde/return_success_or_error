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
    return "Success: $result";
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
    return "Error: $result";
  }
}

/// Representation of void as a result
final class Unit {
  static final Unit _instance = Unit._();
  
  factory Unit() => _instance;
  
  Unit._();
  
  @override
  String toString() {
    return 'Unit{} - void';
  }
}

/// Getter for loading the Unit instance
Unit get unit => Unit();

/// Representation of null as a result
final class Nil {
  static final Nil _instance = Nil._();
  
  factory Nil() => _instance;
  
  Nil._();
  
  @override
  String toString() {
    return 'Nil{} - null';
  }
}

/// Getter for loading the Nil instance
Nil get nil => Nil();
