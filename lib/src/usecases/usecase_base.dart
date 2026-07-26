import 'package:meta/meta.dart';

import '../core/return_success_or_error.dart';
import '../parameters/parameters.dart';
import 'usecase_executor_base.dart';

/// Assinatura da regra de negócio pura de [UsecaseBase] (sem fonte de dados).
///
/// Recebe os [parameters] **já tipados** — sem cast — e devolve o resultado.
///
/// **Deve ser uma função estática ou top-level** (tear-off que não captura
/// `this`): é ela que roda dentro do `Isolate.run` quando `runInIsolate` é
/// `true`.
typedef ProcessPure<TValue, TParams extends Parameters, TError> =
    ReturnSuccessOrError<TValue, TError> Function(TParams parameters);

/// Caso de uso de **lógica pura**: sem fonte de dados externa.
///
/// A subclasse fornece o getter [process] (apontando para uma função estática) e
/// o [onUnexpected]; a base orquestra a execução — direta ou em [Isolate] — e a
/// medição opcional de tempo.
///
/// ```dart
/// final class FibonacciUsecase
///     extends UsecaseBase<int, FibonacciParameters, FibonacciError> {
///   const FibonacciUsecase({super.runInIsolate});
///
///   @override
///   ProcessPure<int, FibonacciParameters, FibonacciError> get process =>
///       _process;
///
///   @override
///   FibonacciError onUnexpected(Object exception, StackTrace stackTrace) =>
///       FibonacciUnexpected('Falha inesperada: $exception');
///
///   static ReturnSuccessOrError<int, FibonacciError> _process(
///     FibonacciParameters parameters,
///   ) => parameters.n < 0
///       ? Failure(NegativeIndex('n deve ser >= 0'))
///       : Success(_fib(parameters.n));
/// }
/// ```
abstract base class UsecaseBase<TValue, TParams extends Parameters, TError>
    extends UsecaseExecutorBase<TValue, TError> {
  const UsecaseBase({super.runInIsolate, super.monitorExecutionTime});

  /// A regra de negócio: uma função **estática** que recebe os parâmetros
  /// tipados e devolve o resultado. Veja [ProcessPure].
  @protected
  ProcessPure<TValue, TParams, TError> get process;

  /// Executa o caso de uso: roda o [process] (direto ou em isolate) e, quando
  /// [monitorExecutionTime] é `true`, mede o tempo total.
  Future<ReturnSuccessOrError<TValue, TError>> call(TParams parameters) {
    // Avalia o tear-off aqui, no isolate principal: a closure enviada ao
    // Isolate.run fecha apenas sobre a função estática e os parâmetros.
    final processFunction = process;
    return measured(() => processStage(() => processFunction(parameters)));
  }
}
