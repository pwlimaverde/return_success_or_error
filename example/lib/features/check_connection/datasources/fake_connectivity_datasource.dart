import 'package:return_success_or_error/return_success_or_error.dart';

/// Simulates an external connectivity check (stands in for a real plugin/API).
///
/// Implements [Datasource]: returns the raw `bool` on success, or `throw`s the
/// [AppError] carried by the parameters on failure — exactly what the usecase's
/// `resultDatasource` expects.
final class FakeConnectivityDatasource implements Datasource<bool> {
  final bool _online;
  final bool _shouldThrow;

  // Private named parameters (Dart 3.12): callers use `online`/`shouldThrow`,
  // while the fields stay private.
  const FakeConnectivityDatasource({
    this._online = true,
    this._shouldThrow = false,
  });

  @override
  Future<bool> call(ParametersReturnResult parameters) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    if (_shouldThrow) {
      throw parameters.error.copyWith(message: "simulated network failure");
    }
    return _online;
  }
}
