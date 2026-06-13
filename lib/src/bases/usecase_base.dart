import 'dart:developer';
import 'dart:isolate';

import '../../return_success_or_error.dart';

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

/// Pure business rule, without any external (datasource) call.
abstract base class UsecaseBase<TypeUsecase>
    with _UsecaseRunner<TypeUsecase> {}

/// Business rule that consumes a [Datasource].
///
/// [TypeUsecase] is the type returned by the usecase; [TypeDatasource] is the
/// raw type returned by the datasource. The datasource is provided through the
/// constructor and kept **private**: subclasses never touch it directly — they
/// invoke [resultDatasource], which is the single bridge between usecase and
/// datasource.
///
/// Subclasses forward the datasource with a super parameter:
/// ```dart
/// final class MyUsecase extends UsecaseBaseCallData<Foo, Bar> {
///   MyUsecase({required super.datasource});
///
///   @override
///   Future<ReturnSuccessOrError<Foo>> call(MyParams parameters) async {
///     final result = await resultDatasource(parameters);
///     return switch (result) { ... };
///   }
/// }
/// ```
abstract base class UsecaseBaseCallData<TypeUsecase, TypeDatasource>
    with _UsecaseRunner<TypeUsecase> {
  final Datasource<TypeDatasource> _datasource;

  /// The datasource is received as a private named parameter (Dart 3.12): the
  /// caller uses the public name `datasource`, but the field stays private.
  UsecaseBaseCallData({required this._datasource});

  /// Invokes the datasource within a `try/catch`, wrapping the outcome in a
  /// [ReturnSuccessOrError]. On failure, the original [AppError] message is
  /// preserved and enriched (via `copyWith`) with the catch context.
  Future<ReturnSuccessOrError<TypeDatasource>> resultDatasource(
    covariant ParametersReturnResult parameters,
  ) async {
    final messageError = parameters.error.message;
    try {
      final result = await _datasource(parameters);

      return SuccessReturn(success: result);
    } catch (e) {
      return ErrorReturn(
        error: parameters.error.copyWith(
          message: "$messageError - Cod. 02-1 --- Catch: $e",
        ),
      );
    }
  }
}
