import '../../return_success_or_error.dart';
import '../mixins/repository_mixin.dart';

abstract base class UsecaseBase<TypeUsecase, TypeDatasource>
    with RepositoryMixin<TypeDatasource> {
  final Datasource<TypeDatasource> datasource;

  UsecaseBase({required this.datasource});
  Future<({TypeUsecase? result, AppError? error})> call({
    required ParametersReturnResult parameters,
  });
}
