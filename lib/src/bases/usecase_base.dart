import '../../return_success_or_error.dart';

import '../mixins/isolate_mixin.dart';
import '../mixins/repository_mixin.dart';

abstract base class UsecaseBaseCallData<TypeUsecase, TypeDatasource>
    with RepositoryMixin<TypeDatasource> {
  final Datasource<TypeDatasource> datasource;

  UsecaseBaseCallData({required this.datasource});
  Future<ReturnSuccessOrError<TypeUsecase>> call({
    required covariant ParametersReturnResult parameters,
  });
}

abstract base class UsecaseBase<TypeUsecase> with IsolateMixin<TypeUsecase> {
  Future<ReturnSuccessOrError<TypeUsecase>> call(
    covariant ParametersReturnResult parameters,
  );

  Future<ReturnSuccessOrError<TypeUsecase>> callIsolate(
    covariant ParametersReturnResult parameters,
  ) async {
    final RuntimeMilliseconds _runtime = RuntimeMilliseconds();

    if (parameters.basic.showRuntimeMilliseconds) {
      _runtime.startScore();
    }

    final data = await returnIsolate(parameters: parameters, callUsecase: call);

    if (parameters.basic.showRuntimeMilliseconds) {
      _runtime.finishScore();
      print(
          "Execution Time ${this.toString().split("Instance of ")[1].replaceAll("'", "")}: ${_runtime.calculateRuntime()}ms");
    }
    return data;
  }
}
