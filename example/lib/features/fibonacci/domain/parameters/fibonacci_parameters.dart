import 'package:return_success_or_error/return_success_or_error.dart';

/// Parâmetros do `FibonacciUsecase`: **apenas dados**.
///
/// Na v2 todo parâmetro era obrigado a carregar um `AppError`; agora o erro é
/// decidido por camada e os parâmetros voltam a ser só entrada.
final class FibonacciParameters extends Parameters {
  final int n;

  const FibonacciParameters({required this.n});
}
