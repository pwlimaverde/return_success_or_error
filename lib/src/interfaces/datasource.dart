import 'parameters.dart';

/// Abstraction for an external call, typed with the expected data type.
///
/// Implement [call] wrapping the logic in a `try/catch`: return the typed data
/// on success, or `throw` the [AppError] carried by the [ParametersReturnResult]
/// on failure (the usecase's `resultDatasource` captures it).
abstract interface class Datasource<TypeDatasource> {
  Future<TypeDatasource> call(covariant ParametersReturnResult parameters);
}
