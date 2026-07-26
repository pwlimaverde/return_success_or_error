import 'package:return_success_or_error/return_success_or_error.dart';

/// Conjunto **fechado** dos erros da feature Fibonacci.
///
/// Como o usecase é de lógica pura (sem fonte de dados), não há `mapError`: os
/// únicos erros possíveis são o de validação, produzido pelo `process`, e o
/// inesperado, produzido pelo `onUnexpected`.
sealed class FibonacciError extends AppError {
  const FibonacciError(super.message);
}

/// Erro de negócio: `n` fora do domínio da função.
final class NegativeIndex extends FibonacciError {
  const NegativeIndex(super.message);
}

/// O inesperado — alvo do `onUnexpected`.
final class FibonacciUnexpected extends FibonacciError {
  const FibonacciUnexpected(super.message);
}
