import '../../return_success_or_error.dart';

///Responsible for storing and processing the data necessary to execute the
///datasource call.

abstract interface class ParametersReturnResult {
  final AppError error;

  ParametersReturnResult({
    required this.error,
  });
}

///Implementation used when the datasource does not require extra parameters.
///It receives the Error directly.
final class NoParams implements ParametersReturnResult {
  final AppError error;
  NoParams({AppError? error})
      : error = error ??
            ErrorGeneric(
              message: "Error General Error",
            );
}
