import '../../return_success_or_error.dart';

///Implement the datasource by typing with the expected data type. Override the
///call method involving logic in a try catch to return the typed data in case
///of success, or a throw returning the AppError received in the
///ParametersReturnResult.
abstract class Datasource<R> {
  Future<R> call({required ParametersReturnResult parameters});
}
