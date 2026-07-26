import 'package:meta/meta.dart';

/// Erro de domínio como **valor** imutável — não uma exceção a ser lançada.
/// Descreve uma falha *esperada* e trafega entre as camadas dentro de um
/// `Failure`.
///
/// **Base opcional dos erros da sua feature.** Estender [AppError] dá aos seus
/// erros uma [message] comum, um `toString` legível (`"$runtimeType - $message"`)
/// e igualdade por valor — sem precisar reescrever nada. Os erros concretos são
/// então agrupados em uma hierarquia `sealed` da feature, usada como `TError` em
/// `ReturnSuccessOrError`, o que dá consumo exaustivo:
///
/// ```dart
/// sealed class LoginError extends AppError {
///   const LoginError(super.message);
/// }
///
/// final class InvalidCredentials extends LoginError {
///   const InvalidCredentials(super.message);
/// }
///
/// final class AccountLocked extends LoginError {
///   const AccountLocked(super.message);
/// }
/// ```
///
/// `ErrorGeneric` é um caso pronto para o "inesperado" (alvo típico de
/// `onUnexpected`). Herdar de [AppError] é **conveniência, não obrigação**: o
/// `TError` do resultado não tem bound e pode ser qualquer tipo.
///
/// A classe é `base`, então os erros a **estendem** (nunca `implements`) — é o
/// que garante que todo [AppError] realmente herde o comportamento acima, em vez
/// de cair nas versões baseadas em identidade de [Object].
///
/// > **Subclasses com campos adicionais devem sobrescrever [operator ==] e
/// > [hashCode]** incluindo esses campos: a igualdade herdada compara apenas o
/// > [runtimeType] e a [message].
@immutable
abstract base class AppError implements Exception {
  /// Descrição do erro, legível por humanos.
  final String message;

  const AppError(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppError &&
          other.runtimeType == runtimeType &&
          other.message == message;

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() => '$runtimeType - $message';
}
