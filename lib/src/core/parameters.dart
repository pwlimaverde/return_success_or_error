import '../../return_success_or_error.dart';

///Responsible for storing and processing the data necessary to execute the
///datasource call.
abstract class ParametersReturnResult {
  ///Error returned in case of failure to call the datasource.
  final AppError error;

  ParametersReturnResult({required this.error});
}

///Implementation used when the datasource does not require extra parameters.
///It receives the Error directly.
class NoParams implements ParametersReturnResult {
  final AppError error;

  NoParams({required this.error});
}
