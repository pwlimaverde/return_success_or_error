abstract class ParametersReturnResult {
  final String messageError;

  ParametersReturnResult({required this.messageError});
}

class NoParams implements ParametersReturnResult {
  final String messageError;

  NoParams({required this.messageError});
}
