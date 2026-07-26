import 'package:meta/meta.dart';

/// Tipo selado que representa o desfecho de uma operação: ou [Success] (o valor
/// de sucesso, do tipo [TValue]) ou [Failure] (o erro, do tipo [TError]).
///
/// **O erro é parametrizado.** Cada feature fecha o seu conjunto de erros
/// possíveis em uma hierarquia `sealed` própria e a usa como [TError]. Como
/// ambos — este tipo e o erro da feature — são selados, o `switch` é
/// **exaustivo nos dois níveis**: o compilador obriga a cobrir sucesso e falha
/// e, dentro da falha, cada erro previsto, sem braço `default`. É esse fecho que
/// garante que nenhum erro que o `Repository` ou o `process` podem produzir fica
/// sem tratamento.
///
/// ```dart
/// // A feature declara o conjunto fechado dos seus erros.
/// sealed class SalesError extends AppError {
///   const SalesError(super.message);
/// }
///
/// final class CsvMalformed extends SalesError {
///   const CsvMalformed(super.message);
/// }
///
/// final class Unexpected extends SalesError {
///   const Unexpected(super.message);
/// }
///
/// // O consumo é exaustivo nos dois níveis.
/// switch (await usecase(parameters)) {
///   case Success(:final value):
///     print(value);
///   case Failure(:final error):
///     switch (error) {
///       case CsvMalformed(): // trata CSV inválido
///       case Unexpected(): // trata o inesperado
///     }
/// }
/// ```
///
/// [TError] **não tem bound**: pode ser qualquer tipo. Herdar de [AppError] é
/// uma conveniência (dá `message`, `toString` e igualdade por valor), não uma
/// obrigação.
@immutable
sealed class ReturnSuccessOrError<TValue, TError> {
  const ReturnSuccessOrError();
}

/// Resultado bem-sucedido, carregando o [value] de tipo [TValue].
///
/// Diferente do equivalente em C# (onde o `union` permite `Success<TValue>` com
/// um único parâmetro de tipo), em Dart os casos de um tipo selado genérico
/// precisam repetir todos os parâmetros da base — daí `Success<TValue, TError>`.
/// Na prática o [TError] é inferido pelo contexto:
///
/// ```dart
/// ReturnSuccessOrError<int, SalesError> process(SalesParameters p) =>
///     Success(42); // TError inferido como SalesError
/// ```
@immutable
final class Success<TValue, TError>
    extends ReturnSuccessOrError<TValue, TError> {
  /// O valor produzido pela operação.
  final TValue value;

  const Success(this.value);

  /// Compara pelo [value], **sem olhar os argumentos de tipo**.
  ///
  /// Testar `other is Success<TValue, TError>` seria assimétrico — e portanto
  /// uma violação do contrato de [Object.==], que exige `a == b` ⇔ `b == a`.
  /// Como genéricos são covariantes em Dart, `Success<String, MeuErro>` *é* um
  /// `Success<String, dynamic>`, mas não o inverso; a comparação daria `true`
  /// em um sentido e `false` no outro. Isso apareceria no uso mais comum de
  /// todos — `expect(result, Success('x'))`, em que o `TError` do literal não
  /// tem como ser inferido e vira `dynamic`.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<Object?, Object?> && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success: $value';
}

/// Resultado com falha, carregando o [error] de tipo [TError].
///
/// Vale a mesma observação de [Success] sobre os dois parâmetros de tipo. Uma
/// consequência prática: como `Failure<A, TError>` **não** é um
/// `ReturnSuccessOrError<B, TError>`, o curto-circuito entre camadas (o erro do
/// fetch subindo como erro do usecase) reconstrói o caso — `Failure(error)` —
/// em vez de repassar a mesma instância.
@immutable
final class Failure<TValue, TError>
    extends ReturnSuccessOrError<TValue, TError> {
  /// O erro que descreve a falha.
  final TError error;

  const Failure(this.error);

  /// Compara pelo [error], sem olhar os argumentos de tipo — pelo mesmo motivo
  /// de simetria explicado em [Success.==].
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<Object?, Object?> && other.error == error;

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Failure: $error';
}
