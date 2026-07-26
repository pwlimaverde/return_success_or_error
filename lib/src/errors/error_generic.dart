import 'app_error.dart';

/// Implementação concreta e genérica de [AppError].
///
/// Use quando não houver necessidade de um erro de domínio específico — em
/// especial como o caso "inesperado" da hierarquia de erros de uma feature, o
/// alvo típico de `onUnexpected` e do braço `default` de um `mapError`.
///
/// Herda [AppError.message], `toString` (`"ErrorGeneric - $message"`) e a
/// igualdade por valor da base; não reimplementa nada.
final class ErrorGeneric extends AppError {
  const ErrorGeneric(super.message);
}
