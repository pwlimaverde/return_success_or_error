import '../../return_success_or_error.dart';

///Responsible for storing and processing the data necessary to execute the
///datasource call.

final class ParametersBasic {
  ///Error returned in case of failure to call the datasource.
  final AppError error;

  ///Bool responsible for activating the log of the time elapsed in the
  ///execution of the function.
  final bool showRuntimeMilliseconds;

  ///Bool responsible for controller activ isolate.
  final bool isIsolate;

  ParametersBasic({
    AppError? error,
    bool? showRuntimeMilliseconds,
    bool? isIsolate,
  })  : error = error ??
            ErrorGeneric(
              message: "Error General Feature",
            ),
        showRuntimeMilliseconds = showRuntimeMilliseconds ?? false,
        isIsolate = isIsolate ?? false;
}

abstract interface class ParametersReturnResult {
  final ParametersBasic basic;

  ParametersReturnResult({required this.basic});
}

///Implementation used when the datasource does not require extra parameters.
///It receives the Error directly.
final class NoParams implements ParametersReturnResult {
  final ParametersBasic basic;

  NoParams({required this.basic});
}

final class NoParamsGeneral implements ParametersReturnResult {
  @override
  ParametersBasic get basic => ParametersBasic();
}
