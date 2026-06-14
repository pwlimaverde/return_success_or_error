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
  you to handle both cases via an exhaustive `switch`.
- **Clear separation of concerns.** The business rule (usecase) is decoupled from the
  external call (datasource); the datasource is encapsulated and reached through a single
  bridge.
- **Optional background processing.** Any usecase can run on a background isolate by
  constructing it with `runInIsolate: true`, keeping the app responsive during heavy work.

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
UsecaseBaseCallData.call
  │  PHASE 1 — fetch: _datasource(parameters)  // private, on the main isolate
  │              └► throw parameters.error  (failure)  →  ErrorReturn<D> (Cod. 02-1)
  │              └► raw value D            (success)  →  SuccessReturn<D>
  ▼
  │  PHASE 2 — short-circuit: if ErrorReturn, return the error (process is NOT called)
  ▼
  │  PHASE 3 — process(D, parameters)          // static function, direct or in isolate
  ▼
ReturnSuccessOrError<T>   →   switch (exhaustive pattern matching)
```

Key points:

- The base **orchestrates everything**: it calls the datasource, short-circuits on error, and
  only then calls `process` with the **raw, already-loaded** data. The subclass implements
  only the `process` getter (a static function) — it never touches the (private) datasource.
- The datasource signals failure by **throwing** `parameters.error`; the base catches it and
  returns an `ErrorReturn` whose message is **enriched** (via `copyWith`) with the catch
  context (`Cod. 02-1`) — the original error type is preserved.
- The fetch (phase 1) always runs on the **main isolate**, so datasources holding native
  resources (database connection, socket) work normally. With `runInIsolate: true`, only
  `process` (phase 3) runs on a background isolate — see
  [Running on a background isolate](#running-on-a-background-isolate).

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

> Since `AppError` is an interface used with `implements`, it only enforces `message` and
> `copyWith` — there is no behavior inheritance. Value equality (`==`/`hashCode`) and a
> readable `toString` do **not** come for free: override them in your custom error when you
> want to compare it by value (handy in tests) or print it in a friendly way, like
> `ErrorGeneric` does.

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
parameters.error` on failure (the base's fetch phase captures it):

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
(`{required super.datasource}`) and kept **private** in the base class. The subclass only
implements the `process` getter, pointing to a **static** function that receives the raw data
already loaded by the datasource (the base does the fetch and the short-circuit on error):

```dart
final class CheckConnectUsecase extends UsecaseBaseCallData<String, bool> {
  CheckConnectUsecase({required super.datasource});

  @override
  ProcessData<String, bool> get process => _process;

  static ReturnSuccessOrError<String> _process(
    bool online,
    ParametersReturnResult parameters,
  ) => online
      ? const SuccessReturn(success: "You are connected")
      : ErrorReturn(error: parameters.error.copyWith(message: "You are offline"));
}
```

> `process` **must be static** (or top-level): it is what runs in the isolate when
> `runInIsolate: true`, and an instance function would capture `this` — dragging the datasource
> (and its native resources) into the isolate. That's why it receives everything via parameters.
> If you need specific fields from the parameter, cast `parameters` to your concrete type inside
> the function.

#### b) Business rule only — `UsecaseBase<TypeUsecase>`

When there is no external call, implement `process` taking just the parameters:

```dart
final class TwoPlusTwoUsecase extends UsecaseBase<int> {
  const TwoPlusTwoUsecase({super.runInIsolate});

  @override
  ProcessPure<int> get process => _process;

  static ReturnSuccessOrError<int> _process(ParametersReturnResult parameters) =>
      const SuccessReturn(success: 4);
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

You can also use Dart 3 destructuring patterns for a more concise syntax:

```dart
final message = switch (data) {
  SuccessReturn(:final result) => 'OK: $result',
  ErrorReturn(:final result) => 'Fail: ${result.message}',
};
```

### 7. Running on a background isolate

Both base classes accept `runInIsolate: true` in the constructor. When enabled, only
`process` runs on a background isolate via `Isolate.run`; when disabled (the default), it runs
inline. In `UsecaseBaseCallData`, the **datasource fetch always runs on the main isolate** —
only the processing (phase 3) goes to the isolate. To measure and log the elapsed time (via
`dart:developer`, with a `(Direct)`/`(Isolate)` suffix), also enable
`monitorExecutionTime: true` — off by default, keeping production cost at zero:

```dart
final usecase = MyUsecase(runInIsolate: true, monitorExecutionTime: true);
final result = await usecase(parameters);
```

> Since `process` is static, it does **not** capture the datasource. Only the raw data (input)
> and the result (output) cross the isolate boundary — both must be *sendable*. That's why the
> datasource can hold non-sendable resources (sockets, database connections): they stay on the
> main isolate and never go to the worker.
>
> **When to enable:** `Isolate.run` has a fixed cost (spawn + serializing the input/output),
> which scales with the data size. It pays off for **heavy** processing (parsing large lists,
> aggregations); for light transforms the overhead outweighs the gain — keep
> `runInIsolate: false`. Use `monitorExecutionTime` to compare both paths.

### 8. Results without a value — `Unit` / `Nil`

For usecases that succeed without producing a value, use the shared singletons `unit`
(stands for `void`) or `nil` (stands for `null`):

```dart
final class LogoutUsecase extends UsecaseBase<Unit> {
  const LogoutUsecase();

  @override
  ProcessPure<Unit> get process => _process;

  static ReturnSuccessOrError<Unit> _process(ParametersReturnResult parameters) {
    // ... perform side effect ...
    return const SuccessReturn(success: unit);
  }
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
via `runInIsolate: true`. Run it with `dart run bin/example.dart` and the tests with `dart test`.

## Environment

- Dart SDK `^3.12.0` (uses Dart 3 features: sealed classes, pattern matching, class
  modifiers, and Dart 3.12 private named parameters).
- Depends only on `package:meta` (for `@protected`/`@immutable`) — no Flutter.
