import 'package:return_success_or_error/return_success_or_error.dart';

import '../parameters/fibonacci_parameters.dart';

/// Regra de negócio pura (sem chamada externa): calcula o n-ésimo número de
/// Fibonacci.
///
/// Estende [UsecaseBase] por não envolver nenhum datasource. A subclasse
/// implementa o getter [process] apontando para uma função **estática** — assim
/// o cálculo pode rodar em um isolate (`runInIsolate: true`) sem capturar a
/// instância do usecase.
final class FibonacciUsecase extends UsecaseBase<int> {
  const FibonacciUsecase({super.runInIsolate});

  @override
  ProcessPure<int> get process => _process;

  /// Função estática: recebe os parâmetros (com cast para o tipo concreto) e
  /// devolve o resultado. Não acessa campos da instância.
  static ReturnSuccessOrError<int> _process(ParametersReturnResult parameters) {
    final params = parameters as FibonacciParameters;
    if (params.n < 0) {
      return ErrorReturn(
        error: params.error.copyWith(message: "n must be >= 0"),
      );
    }
    return SuccessReturn(success: _fib(params.n));
  }

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
