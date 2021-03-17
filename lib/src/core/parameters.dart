import '../../return_success_or_error.dart';

abstract class ParametersReturnResult {
  final AppError error;

  ParametersReturnResult({required this.error});
}

class NoParams implements ParametersReturnResult {
  final AppError error;

  NoParams({required this.error});
}
