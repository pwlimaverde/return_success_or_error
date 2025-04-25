import 'dart:isolate';

import '../../return_success_or_error.dart';

import '../mixins/repository_mixin.dart';

abstract base class UsecaseBaseCallData<TypeUsecase, TypeDatasource>
    with RepositoryMixin<TypeDatasource> {
  final Datasource<TypeDatasource> datasource;

  UsecaseBaseCallData(this.datasource);

  Future<ReturnSuccessOrError<TypeUsecase>> call(
    covariant ParametersReturnResult parameters,
  );

  Future<ReturnSuccessOrError<TypeUsecase>> callIsolate(
    covariant ParametersReturnResult parameters,
  ) async {

    final RuntimeMilliseconds _runtime = RuntimeMilliseconds();

    _runtime.startScore();

    final data = Isolate.run((){
      return call(parameters);
    });

    _runtime.finishScore();
    print(
        "Execution Time ${this.toString().split("Instance of ")[1].replaceAll("'", "")}: ${_runtime.calculateRuntime()}ms");

    return data;
  }
}

abstract base class UsecaseBase<TypeUsecase> {
  Future<ReturnSuccessOrError<TypeUsecase>> call(
    covariant ParametersReturnResult parameters,
  );

  Future<ReturnSuccessOrError<TypeUsecase>> callIsolate(
    covariant ParametersReturnResult parameters,
  ) async {

    final RuntimeMilliseconds _runtime = RuntimeMilliseconds();

    _runtime.startScore();

    final data = Isolate.run((){
      return call(parameters);
    });

    _runtime.finishScore();
    print(
        "Execution Time ${this.toString().split("Instance of ")[1].replaceAll("'", "")}: ${_runtime.calculateRuntime()}ms");

    return data;
  }
}
