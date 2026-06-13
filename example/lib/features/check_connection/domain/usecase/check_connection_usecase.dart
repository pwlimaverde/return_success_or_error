import 'package:return_success_or_error/return_success_or_error.dart';

/// Business rule that consumes a `Datasource<bool>` and maps it to a message.
///
/// Extends [UsecaseBaseCallData]: `String` is what the usecase returns, `bool`
/// is the raw datasource type. The datasource is forwarded through the
/// constructor (`super.datasource`) and stays private — the subclass only calls
/// `resultDatasource` and `switch`es over the result.
final class CheckConnectionUsecase extends UsecaseBaseCallData<String, bool> {
  CheckConnectionUsecase({required super.datasource});

  @override
  Future<ReturnSuccessOrError<String>> call(
    ParametersReturnResult parameters,
  ) async {
    final result = await resultDatasource(parameters);

    return switch (result) {
      SuccessReturn<bool>() => result.result
          ? const SuccessReturn(success: "You are connected")
          : ErrorReturn(
              error: parameters.error.copyWith(message: "You are offline"),
            ),
      ErrorReturn<bool>() => ErrorReturn(error: result.result),
    };
  }
}
