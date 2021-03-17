import '../../../abstractions/datasource.dart';
import '../../../abstractions/repository.dart';
import '../../../core/parameters.dart';
import '../../../core/return_success_or_error_class.dart';

class ReturnResultRepository<T> extends Repository<T> {
  final Datasource<T> datasource;

  ReturnResultRepository({required this.datasource});

  @override
  Future<ReturnSuccessOrError<T>> call(
      {required ParametersReturnResult parameters}) async {
    final result = await returnDatasource(
      datasource: datasource,
      parameters: parameters,
    );
    return result;
  }
}
