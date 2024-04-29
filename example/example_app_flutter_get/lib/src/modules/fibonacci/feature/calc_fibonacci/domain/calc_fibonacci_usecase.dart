import 'package:return_success_or_error/return_success_or_error.dart';

import '../../../../../utils/parameters.dart';

final class CalcFibonacciUsecase extends UsecaseBase<int> {
  @override
  Future<ReturnSuccessOrError<int>> call(
    covariant ParametrosFibonacci parameters,
  ) async {
    try {
      final data = _fibonacci(parameters.num);
      return SuccessReturn<int>(success: data);
    } catch (e) {
      return ErrorReturn<int>(
        error: ErrorGeneric(
          message: 'Error $e',
        ),
      );
    }
  }

  int _fibonacci(int n) {
    if (n == 0 || n == 1) return n;
    return _fibonacci(n - 1) + _fibonacci(n - 2);
  }
}

typedef CalcFibonacci = UsecaseBase<int>;
