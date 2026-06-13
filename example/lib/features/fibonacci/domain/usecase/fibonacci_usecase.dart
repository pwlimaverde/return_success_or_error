import 'package:return_success_or_error/return_success_or_error.dart';

import '../parameters/fibonacci_parameters.dart';

/// Pure business rule (no external call): computes the n-th Fibonacci number.
///
/// Extends [UsecaseBase] because there is no datasource involved. Suited for
/// [UsecaseBase.callIsolate], which runs the computation on a background isolate.
final class FibonacciUsecase extends UsecaseBase<int> {
  @override
  Future<ReturnSuccessOrError<int>> call(FibonacciParameters parameters) async {
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
