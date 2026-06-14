import 'package:return_success_or_error/return_success_or_error.dart';

import '../parameters/fibonacci_parameters.dart';

/// Regra de negócio pura (sem chamada externa): calcula o n-ésimo número de
/// Fibonacci.
///
/// Estende [UsecaseBase] por não envolver nenhum datasource. Para rodar o
/// cálculo em um isolate de background, construa o usecase com
/// `runInIsolate: true` (encaminhado via `super.runInIsolate`) e invoque-o
/// normalmente.
final class FibonacciUsecase extends UsecaseBase<int> {
  const FibonacciUsecase({super.runInIsolate});

  @override
  Future<ReturnSuccessOrError<int>> run(FibonacciParameters parameters) async {
    if (parameters.n < 0) {
      return ErrorReturn(
        error: parameters.error.copyWith(message: "n must be >= 0"),
      );
    }
    return SuccessReturn(success: _fib(parameters.n));
  }

  int _fib(int n) {
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
