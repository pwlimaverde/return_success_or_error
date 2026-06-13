import 'package:meta/meta.dart';

import '../../return_success_or_error.dart';

/// Carries the data required to execute the datasource call.
///
/// Pure interface: implementations must expose the [AppError] returned in case
/// of failure. Implement it with `implements` and declare your own fields.
abstract interface class ParametersReturnResult {
  /// The error returned when the call fails.
  AppError get error;
}

/// Implementation used when the datasource does not require extra parameters.
///
/// Optionally receives the [error]; otherwise falls back to a generic one.
@immutable
final class NoParams implements ParametersReturnResult {
  @override
  final AppError error;

  NoParams({AppError? error})
    : error =
          error ??
          const ErrorGeneric(message: "NoParams: unspecified generic error");
}
