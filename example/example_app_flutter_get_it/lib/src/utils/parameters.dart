import 'package:return_success_or_error/return_success_or_error.dart';

final class ParametrosFibonacci implements ParametersReturnResult {
  final int num;
  @override
  final AppError error;

  ParametrosFibonacci({
    required this.num,
    required this.error,
  });
}
