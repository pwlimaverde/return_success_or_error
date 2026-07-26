import 'package:return_success_or_error/return_success_or_error.dart';

import '../errors/fibonacci_errors.dart';
import '../parameters/fibonacci_parameters.dart';

/// Regra de negócio pura (sem chamada externa): calcula o n-ésimo número de
/// Fibonacci.
///
/// Estende [UsecaseBase] por não envolver nenhuma fonte de dados. O `process` é
/// uma função **estática**, então o cálculo pode rodar em um isolate
/// (`runInIsolate: true`) sem capturar a instância do usecase.
final class FibonacciUsecase
    extends UsecaseBase<int, FibonacciParameters, FibonacciError> {
  const FibonacciUsecase({super.runInIsolate, super.monitorExecutionTime});

  @override
  ProcessPure<int, FibonacciParameters, FibonacciError> get process => _process;

  @override
  FibonacciError onUnexpected(Object exception, StackTrace stackTrace) =>
      FibonacciUnexpected('Falha ao calcular Fibonacci: $exception');

  /// Recebe os parâmetros **já tipados** — na v2 era preciso fazer
  /// `parameters as FibonacciParameters` aqui dentro.
  static ReturnSuccessOrError<int, FibonacciError> _process(
    FibonacciParameters parameters,
  ) => parameters.n < 0
      ? const Failure(NegativeIndex('n must be >= 0'))
      : Success(_fib(parameters.n));

  static int _fib(int n) {
    if (n < 2) return n;
    var previous = 0;
    var current = 1;
    for (var i = 2; i <= n; i++) {
      final next = previous + current;
      previous = current;
      current = next;
    }
    return current;
  }
}
