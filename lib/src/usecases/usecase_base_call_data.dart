import 'package:meta/meta.dart';

import '../core/return_success_or_error.dart';
import '../parameters/parameters.dart';
import '../repositories/repository.dart';
import 'usecase_executor_base.dart';

/// Assinatura da regra de negócio de [UsecaseBaseCallData].
///
/// Recebe o dado **bruto já carregado** pelo repositório (o valor de sucesso, já
/// desempacotado) e os [parameters] **já tipados** — sem cast.
///
/// **Deve ser uma função estática ou top-level** (tear-off que não captura
/// `this`): é ela que roda dentro do `Isolate.run` quando `runInIsolate` é
/// `true`, e capturar `this` arrastaria o repositório (e seus recursos nativos)
/// para o isolate.
typedef ProcessData<TValue, TData, TParams extends Parameters, TError> =
    ReturnSuccessOrError<TValue, TError> Function(
      TData data,
      TParams parameters,
    );

/// Caso de uso **com fonte de dados**, dependente de um [Repository] (DIP — é o
/// que o torna portável: troca-se a fonte sem tocar na regra).
///
/// A base orquestra três fases:
/// 1. **Fetch** — chama o repositório, que já devolve `Success | Failure` (a
///    fronteira traduziu a exceção via `mapError`). Roda sempre no isolate
///    principal.
/// 2. **Curto-circuito** — se o fetch falhou, o erro é devolvido de imediato; o
///    [process] **não** é chamado.
/// 3. **Process** — com o dado bruto em mãos, executa o [process] (direto ou em
///    [Isolate], conforme `runInIsolate`).
///
/// O repositório é mantido **privado**: a subclasse nunca o acessa, apenas
/// fornece o [process] e o `onUnexpected`.
///
/// ```dart
/// final class CheckConnectionUsecase extends UsecaseBaseCallData<
///     String, bool, NoParams, ConnectionError> {
///   const CheckConnectionUsecase({required super.repository});
///
///   @override
///   ProcessData<String, bool, NoParams, ConnectionError> get process =>
///       _process;
///
///   @override
///   ConnectionError onUnexpected(Object exception, StackTrace stackTrace) =>
///       ConnectionUnexpected('Falha inesperada: $exception');
///
///   static ReturnSuccessOrError<String, ConnectionError> _process(
///     bool online,
///     NoParams parameters,
///   ) => online
///       ? const Success('online')
///       : const Failure(Offline('sem conexão'));
/// }
/// ```
abstract base class UsecaseBaseCallData<
  TValue,
  TData,
  TParams extends Parameters,
  TError
>
    extends UsecaseExecutorBase<TValue, TError> {
  final Repository<TData, TParams, TError> _repository;

  /// O repositório é recebido como private named parameter (Dart 3.12): o
  /// chamador usa o nome público `repository`, mas o campo permanece privado.
  /// A subclasse encaminha com `{required super.repository}`.
  const UsecaseBaseCallData({
    required this._repository,
    super.runInIsolate,
    super.monitorExecutionTime,
  });

  /// A regra de negócio: uma função **estática** que recebe o dado bruto já
  /// carregado e os parâmetros tipados. Veja [ProcessData].
  @protected
  ProcessData<TValue, TData, TParams, TError> get process;

  /// Executa o caso de uso: fetch → curto-circuito no erro → process.
  ///
  /// Quando [monitorExecutionTime] é `true`, mede o tempo total (fetch +
  /// process).
  Future<ReturnSuccessOrError<TValue, TError>> call(TParams parameters) =>
      measured(() => _run(parameters));

  Future<ReturnSuccessOrError<TValue, TError>> _run(TParams parameters) async {
    // Fase 1 — fetch. Um Repository bem-comportado (todo RepositoryBase é) já
    // devolve Success|Failure e nunca lança. O try/catch aqui é a rede para o
    // caso de uma implementação manual de Repository quebrar esse contrato:
    // sem ele, a exceção escaparia do usecase e furaria a garantia central da
    // biblioteca — a de que o chamador sempre recebe um valor, nunca um throw.
    final ReturnSuccessOrError<TData, TError> fetchResult;
    try {
      fetchResult = await _repository(parameters);
    } catch (exception, stackTrace) {
      return Failure(onUnexpected(exception, stackTrace));
    }

    switch (fetchResult) {
      // Fase 2 — curto-circuito. O caso é reconstruído porque
      // Failure<TData, TError> não é um ReturnSuccessOrError<TValue, TError>.
      case Failure(:final error):
        return Failure(error);
      // Fase 3 — processa o dado bruto (direto ou em isolate).
      case Success(:final value):
        // Avalia o tear-off aqui, no isolate principal.
        final processFunction = process;
        return processStage(() => processFunction(value, parameters));
    }
  }
}
