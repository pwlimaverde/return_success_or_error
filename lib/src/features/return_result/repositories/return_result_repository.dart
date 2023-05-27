import '../../../interfaces/errors.dart';
import '../../../mixins/return_datasource_mixin.dart';
import '../../../interfaces/datasource.dart';
import '../../../core/parameters.dart';

final class ReturnResultRepository<TypeDatasource>
    with ReturnDatasourcetMixin<TypeDatasource> {
  final Datasource<TypeDatasource> datasource;

  ReturnResultRepository({
    required this.datasource,
  });

  Future<({TypeDatasource? result, AppError? error})> call({
    required ParametersReturnResult parameters,
  }) async {
    final _result = await returnDatasource(
      parameters: parameters,
      datasource: datasource,
    );
    return _result;
  }
}
