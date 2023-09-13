import '../../return_success_or_error.dart';

import '../mixins/isolate_mixin.dart';
import '../mixins/repository_mixin.dart';

abstract base class UsecaseBaseCallData<TypeUsecase, TypeDatasource>
    with RepositoryMixin<TypeDatasource>, IsolateMixin<TypeUsecase> {
  final Datasource<TypeDatasource> datasource;

  UsecaseBaseCallData({required this.datasource});

  Future<ReturnSuccessOrError<TypeUsecase>> call(
    covariant ParametersReturnResult parameters,
  );

  Future<ReturnSuccessOrError<TypeUsecase>> callIsolate(
    covariant ParametersReturnResult parameters,
  ) async {
    if (call.runtimeType.toString() ==
        '(Object?) => Future<ReturnSuccessOrError<void>>') {
      return call(parameters);
    }

    final RuntimeMilliseconds _runtime = RuntimeMilliseconds();

    _runtime.startScore();

    final data = await returnIsolate(
      parameters: parameters,
      call: call,
    );

    _runtime.finishScore();
    print(
        "Execution Time ${this.toString().split("Instance of ")[1].replaceAll("'", "")}: ${_runtime.calculateRuntime()}ms");

    return data;
  }
}

abstract base class UsecaseBase<TypeUsecase> with IsolateMixin<TypeUsecase> {
  Future<ReturnSuccessOrError<TypeUsecase>> call(
    covariant ParametersReturnResult parameters,
  );

  Future<ReturnSuccessOrError<TypeUsecase>> callIsolate(
    covariant ParametersReturnResult parameters,
  ) async {
    if (call.runtimeType.toString() ==
        '(Object?) => Future<ReturnSuccessOrError<void>>') {
      return call(parameters);
    }

    final RuntimeMilliseconds _runtime = RuntimeMilliseconds();

    _runtime.startScore();

    final data = await returnIsolate(
      parameters: parameters,
      call: call,
    );

    _runtime.finishScore();
    print(
        "Execution Time ${this.toString().split("Instance of ")[1].replaceAll("'", "")}: ${_runtime.calculateRuntime()}ms");

    return data;
  }
}
