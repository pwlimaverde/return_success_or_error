import 'package:return_success_or_error/return_success_or_error.dart';

/// Parâmetros do [FibonacciUsecase]: a posição `n` a calcular e o [AppError]
/// retornado em caso de falha.
final class FibonacciParameters implements ParametersReturnResult {
  final int n;

  @override
  final AppError error;

  const FibonacciParameters({required this.n, required this.error});
}
