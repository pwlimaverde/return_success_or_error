import 'dart:developer';
import 'dart:isolate';

import '../../return_success_or_error.dart';

import '../mixins/repository_mixin.dart';

/// Shared `call`/`callIsolate` contract for both usecase base classes.
///
/// Defines the abstract [call] and a concrete [callIsolate] that runs [call]
/// inside an [Isolate], measuring its execution time.
base mixin _UsecaseRunner<TypeUsecase> {
  Future<ReturnSuccessOrError<TypeUsecase>> call(
    covariant ParametersReturnResult parameters,
  );

  /// Runs [call] on a background isolate via [Isolate.run].
  ///
  /// The elapsed time is logged (only in debug builds) through `dart:developer`.
  /// Note: [Isolate.run] sends the computation to another isolate, so anything
  /// captured by [call] (including the usecase and its datasource) must be
  /// sendable; non-sendable captures will throw at runtime.
  Future<ReturnSuccessOrError<TypeUsecase>> callIsolate(
    covariant ParametersReturnResult parameters,
  ) async {
    final stopwatch = Stopwatch()..start();
    final result = await Isolate.run(() => call(parameters));
    stopwatch.stop();

    bool shouldLog = false;
    assert(() {
      shouldLog = true;
      return true;
    }());
    if (shouldLog) {
      log(
        "Execution Time $runtimeType: ${stopwatch.elapsedMilliseconds}ms",
        name: "return_success_or_error",
      );
    }

    return result;
  }
}

/// Business rule that consumes a [Datasource].
///
/// [TypeUsecase] is the type returned by the usecase; [TypeDatasource] is the
/// raw type returned by the datasource. The datasource is received through the
/// positional constructor and accessed via [RepositoryMixin.resultDatasource].
abstract base class UsecaseBaseCallData<TypeUsecase, TypeDatasource>
    with RepositoryMixin<TypeDatasource>, _UsecaseRunner<TypeUsecase> {
  final Datasource<TypeDatasource> datasource;

  UsecaseBaseCallData(this.datasource);
}

/// Pure business rule, without any external (datasource) call.
abstract base class UsecaseBase<TypeUsecase>
    with _UsecaseRunner<TypeUsecase> {}
