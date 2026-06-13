# return_success_or_error

[Read this page in English](https://github.com/pwlimaverde/return_success_or_error/blob/master/README.md)

[Leia esta página em português](https://github.com/pwlimaverde/return_success_or_error/blob/master/README-pt.md)

A pure **Dart** package that abstracts and simplifies usecases, datasources, parameters and
error handling following the Clean Architecture principles popularized by Uncle Bob. The
result of every call is wrapped in a sealed `ReturnSuccessOrError<T>`, so success and error
must always be handled explicitly.

> It is a pure Dart package: it has **no Flutter dependency** and can be used in any Dart
> project (CLI, server, backend) as well as in Flutter apps.

## Core concepts

| Type | Role |
|------|------|
| `ReturnSuccessOrError<T>` | Sealed result type: either `SuccessReturn<T>` or `ErrorReturn<T>`. |
| `SuccessReturn<T>` | Holds the success value, accessed via `.result` (type `T`). |
| `ErrorReturn<T>` | Holds the failure, accessed via `.result` (type `AppError`). |
| `UsecaseBase<T>` | Pure business rule, without any external call. |
| `UsecaseBaseCallData<T, D>` | Business rule that consumes a `Datasource<D>` and returns `T`. |
| `Datasource<D>` | Abstraction for the external call; returns `D` or throws `parameters.error`. |
| `ParametersReturnResult` | Carries the call data; requires an `AppError error`. |
| `AppError` / `ErrorGeneric` | Immutable error contract / default implementation. |
| `NoParams` | Ready-made `ParametersReturnResult` for calls without extra parameters. |
| `Unit` / `unit` | Represents `void` as a result. |
| `Nil` / `nil` | Represents `null` as a result. |
| `Service` | Singleton helper to standardize DI registration and parallel service startup. |

## Installation

```yaml
dependencies:
  return_success_or_error: ^1.0.0
```

## Handling the result

`ReturnSuccessOrError<T>` is a sealed type, so you can handle it with an exhaustive `switch`:

```dart
switch (result) {
  case SuccessReturn<String>():
    print(result.result); // success value
  case ErrorReturn<String>():
    print(result.result.message); // AppError
}
```

Or, more concisely, with the built-in helpers:

```dart
final message = result.fold(
  onSuccess: (value) => 'OK: $value',
  onError: (error) => 'Fail: ${error.message}',
);

if (result.isSuccess) { /* ... */ }
final valueOrNull = result.getOrNull;
```

## Parameters

Implement `ParametersReturnResult` to carry the data of a call. The only requirement is to
provide an `AppError error`, returned in case of failure:

```dart
final class ParametersFibonacci implements ParametersReturnResult {
  final int num;
  @override
  final AppError error;

  ParametersFibonacci({
    required this.num,
    required this.error,
  });
}
```

When a call needs no extra data, use `NoParams`.

## Datasource

Implement `Datasource<D>` typing it with the data to be returned. Wrap the logic in a
`try/catch` and `throw parameters.error` on failure (the `RepositoryMixin` captures it):

```dart
final class ConnectivityDatasource implements Datasource<bool> {
  final Connectivity _connectivity;

  ConnectivityDatasource(this._connectivity);

  @override
  Future<bool> call(NoParams parameters) async {
    try {
      final result = await _connectivity.checkConnectivity();
      return !result.contains(ConnectivityResult.none);
    } catch (e) {
      throw parameters.error.copyWith(message: "$e");
    }
  }
}
```

> `AppError` is **immutable**: to enrich a message, use `copyWith(message: ...)` instead of
> mutating the error.

## Usecase with an external Datasource call

Extend `UsecaseBaseCallData<TypeUsecase, TypeDatasource>` — the first type is what the
usecase returns, the second is the raw type returned by the datasource. The datasource is
passed through the **positional** constructor. Inside `call`, use `resultDatasource(...)` and
`switch` over its result:

```dart
final class CheckConnectUsecase extends UsecaseBaseCallData<String, bool> {
  CheckConnectUsecase(super.datasource);

  @override
  Future<ReturnSuccessOrError<String>> call(NoParams parameters) async {
    final result = await resultDatasource(
      parameters: parameters,
      datasource: datasource,
    );

    switch (result) {
      case SuccessReturn<bool>():
        return result.result
            ? const SuccessReturn(success: "You are connected")
            : ErrorReturn(error: parameters.error.copyWith(message: "You are offline"));
      case ErrorReturn<bool>():
        return ErrorReturn(error: result.result);
    }
  }
}
```

`resultDatasource(...)` runs the datasource inside a `try/catch` and returns
`SuccessReturn<TypeDatasource>` or an `ErrorReturn` whose message is enriched with
`parameters.error`.

## Usecase with the business rule only

When there is no external call, extend `UsecaseBase<TypeUsecase>`:

```dart
final class TwoPlusTwoUsecase extends UsecaseBase<int> {
  @override
  Future<ReturnSuccessOrError<int>> call(NoParams parameters) async {
    return const SuccessReturn(success: 4);
  }
}
```

## Calling the usecase

Instantiate the usecase and invoke it with `call` (positional parameters):

```dart
final usecase = CheckConnectUsecase(ConnectivityDatasource(Connectivity()));

final data = await usecase(
  NoParams(error: const ErrorGeneric(message: "Connection error")),
);

switch (data) {
  case SuccessReturn<String>():
    // data.result
  case ErrorReturn<String>():
    // data.result.message
}
```

### Running on a background isolate

Both base classes expose `callIsolate(parameters)`, which runs `call` on a background
isolate via `Isolate.run` and logs the elapsed time in debug builds. Note that everything
captured by `call` (the usecase and its datasource) must be sendable to another isolate.

## Suggested feature hierarchy

```
lib/
  features/
    check_connection/
      datasources/
        connectivity_datasource.dart
      domain/
        usecase/
          check_connection_usecase.dart
  main.dart
```

## Examples

The [`example/`](example/) directory contains three Flutter apps demonstrating integration
with different DI/navigation solutions: `get`, `flutter_getit` and `flutter_modular`.

## Environment

- Dart SDK `^3.12.0` (uses Dart 3 features: sealed classes, pattern matching, class modifiers).
