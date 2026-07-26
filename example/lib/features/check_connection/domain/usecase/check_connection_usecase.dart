import 'package:return_success_or_error/return_success_or_error.dart';

import '../errors/connection_errors.dart';

/// Regra de negócio que consome o repositório de conexão e mapeia o `bool` cru
/// para uma mensagem.
///
/// Os quatro parâmetros de tipo são, nesta ordem: o valor produzido (`String`),
/// o dado bruto da fonte (`bool`), os parâmetros (`NoParams`) e o conjunto
/// fechado de erros ([ConnectionError]).
final class CheckConnectionUsecase
    extends UsecaseBaseCallData<String, bool, NoParams, ConnectionError> {
  const CheckConnectionUsecase({required super.repository});

  @override
  ProcessData<String, bool, NoParams, ConnectionError> get process => _process;

  /// Só o **inesperado** passa por aqui: um bug no `process`. Falhas técnicas da
  /// fonte já foram traduzidas pelo `mapError` do repositório.
  @override
  ConnectionError onUnexpected(Object exception, StackTrace stackTrace) =>
      ConnectionUnexpected('Falha ao processar a conexão: $exception');

  /// Função estática (não captura `this`): recebe o `bool` já carregado e
  /// devolve a mensagem ou o erro **de negócio** da feature.
  static ReturnSuccessOrError<String, ConnectionError> _process(
    bool online,
    NoParams parameters,
  ) => online
      ? const Success('You are connected')
      : const Failure(ConnectionOffline('You are offline'));
}
