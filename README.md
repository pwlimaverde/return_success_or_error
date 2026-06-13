# return_success_or_error

[Read this page in English](https://github.com/pwlimaverde/return_success_or_error/blob/master/README.md)

[Leia esta página em português](https://github.com/pwlimaverde/return_success_or_error/blob/master/README-pt.md)

A pure **Dart** package that abstracts and simplifies usecases, datasources, parameters and
error handling following the Clean Architecture principles popularized by Uncle Bob. The
result of every call is wrapped in a sealed `ReturnSuccessOrError<T>`, so success and error
must always be handled explicitly.

> Pure Dart: it has **no Flutter dependency** and runs in any Dart project (CLI, server,
> backend) as well as in Flutter apps.

## Why use it

- **One return type for everything.** Every call resolves to `ReturnSuccessOrError<T>` —
  either `SuccessReturn<T>` or `ErrorReturn<T>`. No exceptions leaking across layers.
- **Errors can't be ignored.** Because the result is a *sealed* type, the compiler forces
  you to handle both cases (an exhaustive `switch`, or one of the helpers).
- **Clear separation of concerns.** The business rule (usecase) is decoupled from the
  external call (datasource); the datasource is encapsulated and reached through a single
  bridge.
- **Optional background processing.** Any usecase can run on a background isolate via
  `callIsolate`, keeping the app responsive during heavy work.

## Core concepts

| Type | Role |
|------|------|
| `ReturnSuccessOrError<T>` | Sealed result type: either `SuccessReturn<T>` or `ErrorReturn<T>`. |
| `SuccessReturn<T>` | Holds the success value, accessed via `.result` (type `T`). |
| `ErrorReturn<T>` | Holds the failure, accessed via `.result` (type `AppError`). |
| `UsecaseBase<T>` | Pure business rule, without any external call. |
| `UsecaseBaseCallData<T, D>` | Business rule that consumes a `Datasource<D>` and returns `T`. |
| `Datasource<D>` | Abstraction for the external call; returns `D` or throws `parameters.error`. |
| `ParametersReturnResult` | Carries the call data; must expose an `AppError error`. |
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

```dart
import 'package:return_success_or_error/return_success_or_error.dart';
```

## How the flow works

A feature flows from the usecase, optionally through a datasource, back into a
`ReturnSuccessOrError`:

```
caller
  │  usecase(parameters)                  // call(parameters) — positional
  ▼
UsecaseBaseCallData.call ──► resultDatasource(parameters)   // the single bridge
                                  │   try { _datasource(parameters) }   // private
                                  ▼
                             Datasource.call ──► throw parameters.error   (failure)
                                  │                 └► raw value D         (success)
                                  ▼
                       SuccessReturn<D> | ErrorReturn<D>   (error enriched via copyWith)
  ◄───────────────────────────────┘
switch (result) { SuccessReturn / ErrorReturn }   // exhaustive handling in the usecase
  ▼
ReturnSuccessOrError<T>   →   switch / fold / isSuccess / getOrNull / getOrElse
```

Key points:

- The usecase **never** touches the datasource directly. It calls `resultDatasource`, which
  is the only place the (private) datasource is invoked.
- The datasource signals failure by **throwing** `parameters.error`; `resultDatasource`
  catches it and returns an `ErrorReturn` whose message is **enriched** (via `copyWith`)
  with the catch context — the original error type is preserved.
- `callIsolate` runs the same `call` on a background isolate (see
  [Running on a background isolate](#running-on-a-background-isolate)).

## Usage, step by step

### 1. Define the error — `AppError` / `ErrorGeneric`

`AppError` is the **immutable** error contract (it implements `Exception`). Use the default
`ErrorGeneric`, or implement your own. To add context as the error bubbles up, never mutate
it — create a copy with `copyWith`:

```dart
const error = ErrorGeneric(message: "Connection error");
final enriched = error.copyWith(message: "Connection error - timeout");
```

A custom error keeps the same contract:

```dart
final class ApiError implements AppError {
  @override
  final String message;
  final int statusCode;

  const ApiError({required this.message, required this.statusCode});

  @override
  ApiError copyWith({String? message}) =>
      ApiError(message: message ?? this.message, statusCode: statusCode);
}
```

### 2. Define the parameters — `ParametersReturnResult` / `NoParams`

`ParametersReturnResult` is a pure interface: the only requirement is to expose the
`AppError` returned on failure. Add whatever data your call needs:

```dart
final class ParametersFibonacci implements ParametersReturnResult {
  final int n;
  @override
  final AppError error;

  const ParametersFibonacci({required this.n, required this.error});
}
```

When a call needs no extra data, use `NoParams`:

```dart
final params = NoParams(error: const ErrorGeneric(message: "Connection error"));
```

### 3. Define the datasource — `Datasource<D>`

Type it with the raw data it returns. Wrap the logic in a `try/catch` and `throw
parameters.error` on failure (the usecase's `resultDatasource` captures it):

```dart
final class ConnectivityDatasource implements Datasource<bool> {
  final Connectivity _connectivity;

  const ConnectivityDatasource(this._connectivity);

  @override
  Future<bool> call(ParametersReturnResult parameters) async {
    try {
      final result = await _connectivity.checkConnectivity();
      return !result.contains(ConnectivityResult.none);
    } catch (e) {
      throw parameters.error.copyWith(message: "$e");
    }
  }
}
```

### 4. Define the usecase

#### a) With an external datasource — `UsecaseBaseCallData<TypeUsecase, TypeDatasource>`

`TypeUsecase` is what the usecase returns; `TypeDatasource` is the raw type from the
datasource. The datasource is forwarded through the constructor with a **super parameter**
(`{required super.datasource}`) and kept **private** in the base class — the subclass never
accesses it directly, it only calls `resultDatasource(parameters)`:

```dart
final class CheckConnectUsecase extends UsecaseBaseCallData<String, bool> {
  CheckConnectUsecase({required super.datasource});

  @override
  Future<ReturnSuccessOrError<String>> call(ParametersReturnResult parameters) async {
    final result = await resultDatasource(parameters);

    return switch (result) {
      SuccessReturn<bool>() => result.result
          ? const SuccessReturn(success: "You are connected")
          : ErrorReturn(error: parameters.error.copyWith(message: "You are offline")),
      ErrorReturn<bool>() => ErrorReturn(error: result.result),
    };
  }
}
```

`resultDatasource` is `@protected` — it exists for subclasses only and is the single bridge
between usecase and datasource, so subclasses cannot bypass it.

#### b) Business rule only — `UsecaseBase<TypeUsecase>`

When there is no external call:

```dart
final class TwoPlusTwoUsecase extends UsecaseBase<int> {
  @override
  Future<ReturnSuccessOrError<int>> call(NoParams parameters) async {
    return const SuccessReturn(success: 4);
  }
}
```

### 5. Call the usecase

Instantiate it and invoke it with `call` (positional parameters):

```dart
final usecase = CheckConnectUsecase(datasource: ConnectivityDatasource(Connectivity()));

final data = await usecase(
  NoParams(error: const ErrorGeneric(message: "Connection error")),
);
```

### 6. Handle the result

`ReturnSuccessOrError<T>` is sealed, so the most explicit way is an exhaustive `switch`:

```dart
switch (data) {
  case SuccessReturn<String>():
    print(data.result);          // success value (String)
  case ErrorReturn<String>():
    print(data.result.message);  // AppError
}
```

Or use the built-in helpers when you only need one value:

```dart
// fold both cases into a single value
final message = data.fold(
  onSuccess: (value) => 'OK: $value',
  onError: (error) => 'Fail: ${error.message}',
);

data.isSuccess;                       // bool
data.isError;                         // bool
data.getOrNull;                       // T? (null on error)
data.getOrElse((error) => 'default'); // T (fallback on error)
```

### 7. Running on a background isolate

Both base classes expose `callIsolate(parameters)`, which runs `call` on a background
isolate via `Isolate.run` and logs the elapsed time in debug builds:

```dart
final result = await usecase.callIsolate(parameters);
```

> Everything captured by `call` (the usecase and its datasource) must be *sendable* to the
> other isolate. Avoid capturing non-sendable objects (open sockets, plugin handles, etc.).

### 8. Results without a value — `Unit` / `Nil`

For usecases that succeed without producing a value, use the shared singletons `unit`
(stands for `void`) or `nil` (stands for `null`):

```dart
final class LogoutUsecase extends UsecaseBase<Unit> {
  @override
  Future<ReturnSuccessOrError<Unit>> call(NoParams parameters) async {
    // ... perform side effect ...
    return SuccessReturn(success: unit);
  }
}
```

### 9. Bootstrap with `Service`

`Service.to` is a singleton that standardizes app startup: register dependencies and start
services in parallel.

```dart
Future<void> startServices() async {
  await Service.to.initDependencies(() async => registerDependencies());
  await Service.to.initServices([
    warmUpCache(),
    openDatabase(),
  ]);
}
```

## Suggested feature hierarchy

```
lib/
  features/
    check_connection/
      datasources/
        connectivity_datasource.dart
      domain/
        parameters/
          check_connection_parameters.dart
        usecase/
          check_connection_usecase.dart
  main.dart
```

## Example

The [`example/`](example/) directory contains a **pure Dart** (CLI) example demonstrating
the package without Flutter: a `UsecaseBaseCallData` consuming a `Datasource` (success,
business error and a captured exception) and a `UsecaseBase` running on a background isolate
via `callIsolate`. Run it with `dart run bin/example.dart` and the tests with `dart test`.

## Environment

- Dart SDK `^3.12.0` (uses Dart 3 features: sealed classes, pattern matching, class
  modifiers, and Dart 3.12 private named parameters).
- Depends only on `package:meta` (for `@protected`/`@immutable`) — no Flutter.
