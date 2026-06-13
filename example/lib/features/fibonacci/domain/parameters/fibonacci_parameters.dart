import 'package:return_success_or_error/return_success_or_error.dart';

/// Parameters for [FibonacciUsecase]: the position `n` to compute and the
/// [AppError] returned on failure.
final class FibonacciParameters implements ParametersReturnResult {
  final int n;

  @override
  final AppError error;

  const FibonacciParameters({required this.n, required this.error});
}
