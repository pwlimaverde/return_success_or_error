import 'package:return_success_or_error/return_success_or_error.dart';

/// Conjunto **fechado** dos erros que a feature de conexão pode produzir.
///
/// Por ser `sealed`, o `switch` sobre um [ConnectionError] é exaustivo: se um
/// caso novo for acrescentado aqui, todo consumo que não o trate para de
/// compilar — o compilador vira a rede de segurança do tratamento de erro.
sealed class ConnectionError extends AppError {
  const ConnectionError(super.message);
}

/// Erro de **negócio**: a verificação funcionou e o resultado é "sem conexão".
/// Produzido pelo `process` do usecase.
final class ConnectionOffline extends ConnectionError {
  const ConnectionOffline(super.message);
}

/// Erro **técnico**: a verificação não pôde ser concluída (timeout, plugin
/// indisponível). Traduzido pelo `mapError` do repositório.
final class ConnectionUnavailable extends ConnectionError {
  const ConnectionUnavailable(super.message);
}

/// O inesperado — alvo do braço `default` do `mapError` e do `onUnexpected`.
final class ConnectionUnexpected extends ConnectionError {
  const ConnectionUnexpected(super.message);
}
