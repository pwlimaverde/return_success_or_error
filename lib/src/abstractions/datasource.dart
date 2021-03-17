import '../../return_success_or_error.dart';

abstract class Datasource<R> {
  Future<R> call({required ParametersReturnResult parameters});
}
