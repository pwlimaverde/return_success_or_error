import '../../return_success_or_error.dart';

///Responsible for storing and processing the data necessary to execute the
///datasource call.
abstract class ParametersReturnResult {
  ///Error returned in case of failure to call the datasource.
  final AppError error;

  ///Bool responsible for activating the log of the time elapsed in the
  ///execution of the function.
  final bool showRuntimeMilliseconds;

  ///String responsible for identifying the feature.
  final String nameFeature;

  const ParametersReturnResult({
    required this.error,
    required this.showRuntimeMilliseconds,
    required this.nameFeature,
  });
}

///Implementation used when the datasource does not require extra parameters.
///It receives the Error directly.
class NoParams implements ParametersReturnResult {
  final AppError error;
  final bool showRuntimeMilliseconds;
  final String nameFeature;

  const NoParams({
    required this.error,
    required this.showRuntimeMilliseconds,
    required this.nameFeature,
  });
}
