import '../core/parameters.dart';

///Implement the datasource by typing with the expected data type. Override the
///call method involving logic in a try catch to return the typed data in case
///of success, or a throw returning the AppError received in the
///ParametersReturnResult.
abstract interface class Datasource<TypeDatasource> {
  Future<TypeDatasource> call({
    required covariant ParametersReturnResult parameters,
  });
}
