# return_success_or_error

[Read this page in English](https://github.com/pwlimaverde/return_success_or_error/blob/master/README.md)

[Leia esta página em português](https://github.com/pwlimaverde/return_success_or_error/blob/master/README-pt.md)

A pure **Dart** package that abstracts and simplifies usecases, datasources, parameters and
error handling following the Clean Architecture principles popularized by Uncle Bob. The
result of every call is wrapped in a sealed `ReturnSuccessOrError<T>`, so success and error
must always be handled explicitly.

> Pure Dart: it has **no Flutter dependency** and runs in any Dart project (CLI, server,
> backend) as well as in Flutter apps.

## The Problem

In apps built with Clean Architecture, each feature follows the flow
**datasource → usecase → UI**. Two recurring pain points emerge from this model:

1. **Heavy processing blocks the UI.** When the usecase needs to parse large
   payloads, aggregate thousands of rows, or transform complex data structures, the
   work runs on the main thread (event loop). In Flutter, that means **dropped frames
   and frozen interfaces** — the user sees the app "hanging" while the CPU is busy.

2. **Datasources can't simply be moved to a background isolate.** A datasource often
   holds native resources — database connections, sockets, platform channels — that are
   **not serializable** and cannot cross the isolate boundary. Sending the entire
   usecase (including its datasource) to `Isolate.run` breaks at runtime.

3. **Errors leak between layers.** Without a standardized result type, exceptions
   thrown by the datasource propagate up unhandled, mixing infrastructure failures
   with business-logic errors and making the code fragile and hard to debug.

### The solution

`return_success_or_error` solves all three by design:

- **Sealed result type** (`ReturnSuccessOrError<T>`) — every call returns either
  `SuccessReturn<T>` or `ErrorReturn<T>`. The compiler forces exhaustive handling via
  `switch`; no exception can silently leak.
- **Fetch/process separation** — the base class orchestrates the datasource call
  (fetch) on the **main isolate**, keeping native resources safe. Only the pure
  processing function (`process`) can optionally run on a **background isolate** via
  `runInIsolate: true`. Since `process` is a static function, it never captures `this`
  nor the datasource — only the raw data and the result cross the isolate boundary.
- **Automatic short-circuit** — if the fetch fails, the error is returned immediately
  and the processing phase is never executed, avoiding unnecessary work.
- **Feature-based organization** — the package naturally guides the separation of each
  feature into well-defined layers (`datasources/`, `domain/model/`,
  `domain/parameters/`, `domain/usecase/`). Each piece has a single responsibility: the
  datasource handles only I/O, the model carries the processed data, the parameters
  define the typed input, and the usecase contains exclusively the business rule — with
  no coupling between them.

#### Concrete example: Sales Report

The `sales_report` example illustrates the full cycle. A datasource queries the
database and returns **50 thousand raw sale rows** (fetch phase, async, on the main
isolate). The usecase receives those already-loaded rows and aggregates total revenue,
average ticket, and best-selling product into a `SalesReport` object (process phase,
CPU-bound, optionally on a background isolate). The UI never freezes:

```
sales_report/
  datasources/
    fake_sales_datasource.dart        ← I/O: queries the database, returns List<Map>
  domain/
    model/
      sales_report.dart               ← Processed object (immutable, sendable)
    parameters/
      sales_report_parameters.dart    ← Typed input (month, year, AppError)
    usecase/
      gerar_sales_report_usecase.dart ← Business rule: parsing + aggregation
```

With `runInIsolate: true`, the heavy processing runs on a background isolate and the
UI stays fluid. With `monitorExecutionTime: true`, you can compare direct vs. isolate
timing and decide which path pays off for each data volume.

## Why use it

- **One return type for everything.** Every call resolves to `ReturnSuccessOrError<T>` —
  either `SuccessReturn<T>` or `ErrorReturn<T>`. No exceptions leaking across layers.
- **Errors can't be ignored.** Because the result is a *sealed* type, the compiler forces
  you to handle both cases via an exhaustive `switch`.
- **Clear separation of concerns.** The business rule (usecase) is decoupled from the
  external call (datasource); the datasource is encapsulated and reached through a single
  bridge.
- **Optional background processing.** Any usecase can run its processing on a background
  isolate by constructing it with `runInIsolate: true`, keeping the app responsive during
  heavy work — while the datasource stays safely on the main isolate.

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
  return_success_or_error: ^2.0.0
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

`ParametersReturnResult` is a pure interface: the only requirement is to expose the `AppError` returned on failure. Add whatever data your API/database call or processing needs:

```dart
final class SalesReportParameters implements ParametersReturnResult {
  final int mes;
  final int ano;

  @override
  final AppError error;

  const SalesReportParameters({
    required this.mes,
    required this.ano,
    required this.error,
  });
}
```

When the call does not need extra data, you can use the `NoParams` helper provided by the library:

```dart
final params = NoParams(error: const ErrorGeneric(message: "Unexpected error"));
```

### 3. Define the datasource — `Datasource<D>`

Type it with the raw data it returns (for example, `List<Map<String, dynamic>>` from the database or raw JSON). Wrap the logic in a `try/catch` and `throw parameters.error` on failure (the usecase's fetch phase automatically captures it and triggers short-circuit):

```dart
final class FakeSalesDatasource implements Datasource<List<Map<String, dynamic>>> {
  const FakeSalesDatasource();

  @override
  Future<List<Map<String, dynamic>>> call(covariant SalesReportParameters parameters) async {
    try {
      // Simulates database query (async I/O that doesn't block the UI)
      await Future.delayed(const Duration(milliseconds: 100));
      return [
        {'produto': 'Produto A', 'quantidade': 10, 'valor_unitario': 50.0},
        {'produto': 'Produto B', 'quantidade': 5, 'valor_unitario': 100.0},
      ];
    } catch (e) {
      throw parameters.error.copyWith(message: "$e");
    }
  }
}
```

### 4. Define the usecase

#### a) With an external datasource — `UsecaseBaseCallData<TypeUsecase, TypeDatasource>`

`TypeUsecase` is the type of the processed domain object returned by the usecase; `TypeDatasource` is the raw type returned by the datasource. The datasource is forwarded through the constructor with a **super parameter** (`{required super.datasource}`) and kept **private** in the base class.

The subclass only implements the `process` getter, pointing to a **static** function that receives the raw data already loaded (the base handles the fetch and the short-circuit on fetch error):

```dart
final class GerarSalesReportUsecase
    extends UsecaseBaseCallData<SalesReport, List<Map<String, dynamic>>> {
  GerarSalesReportUsecase({
    required super.datasource,
    super.runInIsolate,
    super.monitorExecutionTime,
  });

  @override
  ProcessData<SalesReport, List<Map<String, dynamic>>> get process => _process;

  // Static function: essential not to capture "this" so it can run in an Isolate.
  static ReturnSuccessOrError<SalesReport> _process(
    List<Map<String, dynamic>> linhas,
    ParametersReturnResult parameters,
  ) {
    if (linhas.isEmpty) {
      return ErrorReturn(
        error: parameters.error.copyWith(message: "No sales in this period"),
      );
    }

    var faturamento = 0.0;
    var itens = 0;
    for (final row in linhas) {
      final quantidade = row['quantidade'] as int;
      faturamento += quantidade * (row['valor_unitario'] as double);
      itens += quantidade;
    }

    return SuccessReturn(
      success: SalesReport(
        totalItens: itens,
        faturamentoTotal: faturamento,
      ),
    );
  }
}
```

> `process` **must be static** (or top-level): it is what runs in the background isolate when `runInIsolate: true`. An instance function would implicitly capture `this` — dragging the entire datasource (and its native resources like DB drivers or network connections) into the isolate, causing runtime or compilation errors. If you need specific fields from the parameters, cast `parameters` to your concrete type inside `_process`.

#### b) Business rule only — `UsecaseBase<TypeUsecase>`

When there is no external call, extend `UsecaseBase` and implement `process` taking just the parameters. For example, calculating sales commission based on total sales revenue:

```dart
final class CalcularComissaoParameters implements ParametersReturnResult {
  final double valorTotal;
  @override
  final AppError error;

  const CalcularComissaoParameters({required this.valorTotal, required this.error});
}

final class CalcularComissaoUsecase extends UsecaseBase<double> {
  const CalcularComissaoUsecase({super.runInIsolate});

  @override
  ProcessPure<double> get process => _process;

  static ReturnSuccessOrError<double> _process(ParametersReturnResult parameters) {
    final params = parameters as CalcularComissaoParameters;
    return SuccessReturn(success: params.valorTotal * 0.05); // 5% commission
  }
}
```

### 5. Call the usecase

Instantiate it and invoke it passing the concrete parameters:

```dart
final usecase = GerarSalesReportUsecase(
  datasource: const FakeSalesDatasource(),
  runInIsolate: true, // Heavy processing will run in a background Isolate!
);

final data = await usecase(
  SalesReportParameters(
    mes: 6,
    ano: 2026,
    error: const ErrorGeneric(message: "Failed to generate sales report"),
  ),
);
```

### 6. Handle the result

`ReturnSuccessOrError<T>` is a sealed class, ensuring you handle all scenarios exhaustively using a `switch`:

```dart
switch (data) {
  case SuccessReturn<SalesReport>():
    print("Revenue: ${data.result.faturamentoTotal}"); // success value (SalesReport)
  case ErrorReturn<SalesReport>():
    print(data.result.message);                         // AppError
}
```

You can also use Dart 3 destructuring patterns for a more concise syntax:

```dart
final message = switch (data) {
  SuccessReturn(:final result) => 'Success! Revenue: ${result.faturamentoTotal}',
  ErrorReturn(:final result) => 'Failure: ${result.message}',
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
final usecase = GerarSalesReportUsecase(
  datasource: const FakeSalesDatasource(),
  runInIsolate: true,
  monitorExecutionTime: true,
);
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
    sales_report/
      datasources/
        fake_sales_datasource.dart
      domain/
        model/
          sales_report.dart
        parameters/
          sales_report_parameters.dart
        usecase/
          gerar_sales_report_usecase.dart
  main.dart
```

## Example

The [`example/`](example/) directory contains a **pure Dart** (CLI) example demonstrating
the package without Flutter:

- **`check_connection`** — a `UsecaseBaseCallData` consuming a `Datasource` (success,
  business error and a captured exception).
- **`fibonacci`** — a `UsecaseBase` running on a background isolate via `runInIsolate: true`.
- **`sales_report`** — demonstrates the **fetch → process** flow: the datasource returns
  50k raw sale rows (fetch phase, main isolate) and the `process` (static function) aggregates
  them into a `SalesReport` object (processing phase, background isolate). Includes
  `monitorExecutionTime` for comparing direct vs. isolate execution times.

Run it with `dart run bin/example.dart` and the tests with `dart test`.

## Environment

- Dart SDK `^3.12.0` (uses Dart 3 features: sealed classes, pattern matching, class
  modifiers, and Dart 3.12 private named parameters).
- Depends only on `package:meta` (for `@protected`/`@immutable`) — no Flutter.
