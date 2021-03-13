import '../../../abstractions/datasource.dart';
import '../../../abstractions/repository.dart';
import '../../../core/errors.dart';
import '../../../core/parameters.dart';
import '../../../core/return_success_or_error_class.dart';

class ReturnResultRepository<T> extends Repository<T, ParametersReturnResult> {
  final Datasource<T, ParametersReturnResult> datasource;

  ReturnResultRepository({required this.datasource});

  @override
  Future<ReturnSuccessOrError<T>> call(
      {required ParametersReturnResult parameters}) async {
    final result = await returnDatasource(
      datasource: datasource,
      error: ErroReturnResult(
        message: "${parameters.messageError} Cod.02-1",
      ),
      parameters: parameters,
    );
    return result;
  }
}
