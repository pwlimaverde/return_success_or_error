import 'package:meta/meta.dart';

import '../../return_success_or_error.dart';

/// Tipo selado que encapsula o resultado de uma operação como sucesso ou erro.
///
/// A recuperação do dado é feita exclusivamente via pattern matching (switch):
/// ```dart
/// switch (result) {
///   case SuccessReturn(:final result): // valor de sucesso
///   case ErrorReturn(:final result):   // AppError padronizado
/// }
/// ```
@immutable
sealed class ReturnSuccessOrError<R> {
  const ReturnSuccessOrError();

  /// Contrato obrigatório: toda subclasse deve expor seu resultado.
  ///
  /// O tipo concreto é refinado covariantemente em cada subclasse
  /// ([R] em [SuccessReturn], [AppError] em [ErrorReturn]).
  Object? get result;
}

/// Armazena o dado retornado em caso de sucesso.
@immutable
final class SuccessReturn<R> extends ReturnSuccessOrError<R> {
  final R _success;

  const SuccessReturn({required this._success});

  @override
  R get result => _success;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuccessReturn<R> && other._success == _success;

  @override
  int get hashCode => _success.hashCode;

  @override
  String toString() => 'Success: $result';
}

/// Armazena o erro padronizado retornado em caso de falha.
@immutable
final class ErrorReturn<R> extends ReturnSuccessOrError<R> {
  final AppError _error;

  const ErrorReturn({required this._error});

  @override
  AppError get result => _error;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ErrorReturn<R> && other._error == _error;

  @override
  int get hashCode => _error.hashCode;

  @override
  String toString() => 'Error: $result';
}

/// Representação de void como resultado.
@immutable
final class Unit {
  const Unit();

  @override
  String toString() => 'Unit{} - void';
}

/// Instância singleton de [Unit].
const unit = Unit();

/// Representação de null como resultado.
@immutable
final class Nil {
  const Nil();

  @override
  String toString() => 'Nil{} - null';
}

/// Instância singleton de [Nil].
const nil = Nil();
