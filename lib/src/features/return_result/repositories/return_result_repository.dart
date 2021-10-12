import '../../../mixins/return_result_mixin.dart';
import '../../../interfaces/datasource.dart';
import '../../../interfaces/repository.dart';
import '../../../core/parameters.dart';
import '../../../core/return_success_or_error_class.dart';

class ReturnResultRepository<T>
    with ReturnResultMixin<T>
    implements Repository<T> {
  final Datasource<T> datasource;

  ReturnResultRepository({
    required this.datasource,
  });

  @override
  Future<ReturnSuccessOrError<T>> call({
    required ParametersReturnResult parameters,
  }) async {
    final result = await returnDatasource(
      parameters: parameters,
      datasource: datasource,
    );
    return result;
  }
}
