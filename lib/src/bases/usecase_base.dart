import '../../return_success_or_error.dart';
import '../mixins/repository_mixin.dart';

abstract base class UsecaseBaseCallData<TypeUsecase, TypeDatasource>
    with RepositoryMixin<TypeDatasource> {
  final Datasource<TypeDatasource> datasource;

  UsecaseBaseCallData({required this.datasource});
  Future<({TypeUsecase? result, AppError? error})> call({
    required ParametersReturnResult parameters,
  });
}

abstract base class UsecaseBase<TypeUsecase> {
  Future<({TypeUsecase? result, AppError? error})> call({
    required ParametersReturnResult parameters,
  });
}
