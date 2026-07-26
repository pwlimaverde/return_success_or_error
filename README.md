# return_success_or_error

[Read this page in English](https://github.com/pwlimaverde/return_success_or_error/blob/master/README.md)

[Leia esta página em português](https://github.com/pwlimaverde/return_success_or_error/blob/master/README-pt.md)

A pure **Dart** package that abstracts and simplifies usecases, datasources, repositories,
parameters and error handling, following the Clean Architecture principles popularized by
Uncle Bob. The outcome of any call is wrapped in a sealed
`ReturnSuccessOrError<TValue, TError>`, so success and error must always be handled
explicitly — **and every possible error, by name**.

> Pure Dart: it does **not depend on Flutter** and runs in any Dart project (CLI, server,
> backend), as well as in Flutter apps.

## The Problem

In apps built with Clean Architecture, every feature follows the flow
**datasource → usecase → UI**. Four pains keep coming out of that model:

1. **Heavy processing blocks the UI.** When the usecase has to parse large payloads,
   aggregate thousands of rows or transform complex structures, the work runs on the main
   thread (event loop). In Flutter that means **dropped frames and frozen interfaces**.

2. **Datasources can't simply be moved to a background isolate.** A datasource often holds
   native resources — database connections, sockets, platform channels — that are **not
   serializable** and cannot cross the isolate boundary.

3. **Errors leak across layers.** Without a standardized result type, exceptions thrown by
   the datasource propagate unhandled, mixing infrastructure failures with business rule
   errors.

4. **"Handling the error" degenerates into handling *one* generic error.** Even with a
   result type, if the failure is always the same open class, the compiler has no way of
   knowing *which* errors a given call produces. Handling becomes scattered `if (e is X)`
   checks, or a `catch` that swallows everything — and when a new error appears, nothing
   warns you that it is unhandled.

### The solution

- **Parameterized error, closed per feature** — `ReturnSuccessOrError<TValue, TError>`.
  Each feature declares the errors it can produce in a `sealed` hierarchy and uses it as
  `TError`. The `switch` becomes exhaustive **at both levels** (success/failure and, inside
  the failure, every anticipated error) — **with no `default` branch**. Adding a new error
  to the feature breaks compilation of every consumer that doesn't handle it: the compiler
  enforces handling, not the code review.
- **Three layers with an explicit boundary** — `Datasource → Repository → Usecase`. The
  datasource is dumb (returns data or throws); `RepositoryBase` is the anti-corruption
  layer that translates every technical exception into a domain error through `mapError`
  (**abstract**: the compiler requires the mapping); the usecase depends on the
  `Repository`, never on the concrete source.
- **Nothing blows up silently** — if `process` throws an unexpected exception (a bug), it
  is converted by `onUnexpected` (also abstract) into an anticipated error of the feature.
  The usecase **never** propagates an exception to the caller.
- **Fetch/process separation** — the base orchestrates the fetch on the **main isolate**,
  keeping native resources safe. Only `process` (a static, CPU-bound function) may run on a
  **background isolate** via `runInIsolate: true`.
- **Automatic short-circuit** — if the fetch fails, the error is returned right away and
  the processing phase never runs.

#### A concrete example: Sales Report

The `sales_report` example shows the full cycle. A datasource queries the database and
returns **50k raw sales rows** (fetch phase, asynchronous, on the main isolate). The
repository translates a database timeout into `SalesSourceUnavailable`. The usecase takes
the already loaded rows and aggregates revenue, average ticket and best-selling product
into a `SalesReport` (process phase, CPU-bound, optionally on an isolate):

```
sales_report/
  datasources/
    fake_sales_datasource.dart        ← I/O: queries the database, returns List<Map>
  repositories/
    sales_repository.dart             ← Boundary: mapError translates the technical exception
  domain/
    errors/
      sales_report_errors.dart        ← CLOSED set of errors (sealed)
    model/
      sales_report.dart               ← Processed object (immutable, sendable)
    parameters/
      sales_report_parameters.dart    ← Typed input (month, year) — data only
    usecase/
      gerar_sales_report_usecase.dart ← Business rule: parse + aggregation
```

## Core concepts

| Type | Role |
|------|------|
| `ReturnSuccessOrError<TValue, TError>` | Sealed result type: either `Success` or `Failure`. |
| `Success<TValue, TError>` | Holds the success value, read through `.value`. |
| `Failure<TValue, TError>` | Holds the failure, read through `.error` (type `TError`). |
| `Datasource<TData, TParams>` | External call; returns `TData` or **throws** the technical exception. |
| `Repository<TData, TParams, TError>` | Data layer contract; returns an already handled result. |
| `RepositoryBase<TData, TParams, TError>` | Ready-made boundary: calls the source and translates via `mapError`. |
| `UsecaseBase<TValue, TParams, TError>` | Pure business rule, no data source. |
| `UsecaseBaseCallData<TValue, TData, TParams, TError>` | Business rule over the repository data. |
| `Parameters` | The call data — **and data only**. |
| `NoParams` / `noParams` | Empty parameters. |
| `AppError` | Optional base for errors: provides `message`, `toString` and value equality. |
| `ErrorGeneric` | Ready-made concrete case for the "unexpected". |
| `Unit` / `unit` | Represents `void` as a result. |
| `Nil` / `nil` | Represents `null` as a result. |

## Installation

```yaml
dependencies:
  return_success_or_error: ^3.0.0
```

```dart
import 'package:return_success_or_error/return_success_or_error.dart';
```

## How the flow works

```
caller
  │  usecase(parameters)                       // call(parameters) — positional
  ▼
UsecaseBaseCallData.call
  │  (measures total time, if monitorExecutionTime)
  │
  │  PHASE 1 — fetch: repository(parameters)        // on the main isolate
  │              │
  │              └► RepositoryBase.call
  │                   ├► datasource(parameters)  → raw data    → Success<TData, TError>
  │                   └► technical exception     → mapError()  → Failure<TData, TError>
  │              └► (safety net: if the Repository throws → onUnexpected)
  ▼
  │  PHASE 2 — short-circuit: on Failure, return the error (process is NOT called)
  ▼
  │  PHASE 3 — process(data, parameters)            // static function, direct or on isolate
  │              └► unexpected exception        → onUnexpected() → Failure
  ▼
ReturnSuccessOrError<TValue, TError>   →   switch, exhaustive at both levels
```

Key points:

- **No exception crosses the boundary.** The repository translates the technical ones
  (`mapError`); the executor converts the unexpected ones (`onUnexpected`). Both are
  **abstract**: since there is no universal error the base could fabricate, the feature
  decides — and the compiler enforces it.
- **The caller never gets a `throw`.** Both phases are protected: the processing one
  always, and the fetch one as a safety net for a hand-written `Repository` that breaks the
  contract (anything extending `RepositoryBase` never gets there).
- **The stack trace is not lost.** In Dart it doesn't travel inside the exception, so
  `mapError` and `onUnexpected` receive it explicitly — ignore it in simple mappings, use it
  when you need to report the failure (Sentry, Crashlytics, structured logging).
- The fetch (phase 1) **always runs on the main isolate**, so datasources holding native
  resources work normally. With `runInIsolate: true`, only `process` (phase 3) goes to the
  isolate.
- The usecase subclass provides only `process` (a static function) and `onUnexpected` — it
  never touches the repository (which stays private).

## Step-by-step usage

### 1. Declare the feature's closed set of errors

This is where the guarantee lives. A `sealed` hierarchy lists every error the feature can
produce; extending `AppError` gives you `message`, `toString` and value equality for free:

```dart
sealed class SalesReportError extends AppError {
  const SalesReportError(super.message);
}

/// Technical error translated by the repository.
final class SalesSourceUnavailable extends SalesReportError {
  const SalesSourceUnavailable(super.message);
}

/// Business error, produced by process.
final class EmptyPeriod extends SalesReportError {
  const EmptyPeriod(super.message);
}

/// The unexpected one — target of onUnexpected and of mapError's default branch.
final class SalesUnexpected extends SalesReportError {
  const SalesUnexpected(super.message);
}
```

> Extending `AppError` is **convenience, not obligation**: `TError` has no bound and can be
> any type (an enum, a record, your own class). If your subclass adds fields, override
> `==`/`hashCode` to include them — the inherited equality only compares the type and the
> `message`.

### 2. Define the parameters — `Parameters` / `noParams`

`Parameters` carries **data only**. Keep it immutable: the same parameters may cross an
isolate boundary.

```dart
final class SalesReportParameters extends Parameters {
  final int mes;
  final int ano;

  const SalesReportParameters({required this.mes, required this.ano});
}
```

When the call needs no input, use the `noParams` singleton (of type `NoParams`).

### 3. Define the datasource — `Datasource<TData, TParams>`

The dumb layer: it returns the raw data **or lets the exception bubble up**. No
`try/catch`, no domain knowledge.

```dart
final class FakeSalesDatasource
    implements Datasource<List<Map<String, dynamic>>, SalesReportParameters> {
  const FakeSalesDatasource();

  @override
  Future<List<Map<String, dynamic>>> call(SalesReportParameters parameters) async {
    // Async I/O. On failure the exception bubbles up raw — the repository translates it.
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return [
      {'produto': 'Product A', 'quantidade': 10, 'valor_unitario': 50.0},
      {'produto': 'Product B', 'quantidade': 5, 'valor_unitario': 100.0},
    ];
  }
}
```

### 4. Define the repository — `RepositoryBase` and `mapError`

The boundary. It takes the source through `{required super.datasource}` (which stays
private) and implements `mapError`, translating **every** exception into an anticipated
error:

```dart
final class SalesRepository extends RepositoryBase<
    List<Map<String, dynamic>>, SalesReportParameters, SalesReportError> {
  const SalesRepository({required super.datasource});

  @override
  SalesReportError mapError(
    Object exception,
    StackTrace stackTrace,
    SalesReportParameters parameters,
  ) => switch (exception) {
    TimeoutException() => SalesSourceUnavailable(
        'Source unavailable for ${parameters.mes}/${parameters.ano}',
      ),
    _ => SalesUnexpected('Unexpected failure: $exception'),
  };
}
```

From here on the domain only sees `Success | Failure` — no infrastructure exception
crosses this line.

> The `stackTrace` comes along because, in Dart, it **does not travel inside the
> exception**: if the boundary dropped it in the `catch`, the origin of the failure would be
> gone. Ignoring it is fine in simple mappings; this is where reporting to your error
> collector belongs.

### 5. Define the usecase

#### a) With a data source — `UsecaseBaseCallData<TValue, TData, TParams, TError>`

The four type parameters are, in order: the produced value, the raw data from the source,
the parameters and the error set. The subclass provides `process` (a **static** function)
and `onUnexpected`:

```dart
final class GerarSalesReportUsecase extends UsecaseBaseCallData<
    SalesReport, List<Map<String, dynamic>>, SalesReportParameters, SalesReportError> {
  const GerarSalesReportUsecase({
    required super.repository,
    super.runInIsolate,
    super.monitorExecutionTime,
  });

  @override
  ProcessData<SalesReport, List<Map<String, dynamic>>, SalesReportParameters,
      SalesReportError> get process => _process;

  @override
  SalesReportError onUnexpected(Object exception, StackTrace stackTrace) =>
      SalesUnexpected('Failed to process the report: $exception');

  // Static function: essential so it doesn't capture "this" and can run on the Isolate.
  static ReturnSuccessOrError<SalesReport, SalesReportError> _process(
    List<Map<String, dynamic>> rows,
    SalesReportParameters parameters, // already typed: no cast
  ) {
    if (rows.isEmpty) {
      return const Failure(EmptyPeriod('No sales in the period'));
    }

    var revenue = 0.0;
    var items = 0;
    for (final row in rows) {
      final quantity = row['quantidade'] as int;
      revenue += quantity * (row['valor_unitario'] as double);
      items += quantity;
    }

    return Success(SalesReport(totalItens: items, faturamentoTotal: revenue));
  }
}
```

> `process` **must be static** (or top-level): it is what runs on the isolate when
> `runInIsolate: true`. An instance method would implicitly capture `this` — dragging the
> repository and the source (with their native resources) into the isolate.

#### b) Business rule only — `UsecaseBase<TValue, TParams, TError>`

When there is no I/O, `process` receives just the parameters:

```dart
final class CalcularComissaoUsecase
    extends UsecaseBase<double, ComissaoParameters, ComissaoError> {
  const CalcularComissaoUsecase({super.runInIsolate});

  @override
  ProcessPure<double, ComissaoParameters, ComissaoError> get process => _process;

  @override
  ComissaoError onUnexpected(Object exception, StackTrace stackTrace) => ComissaoUnexpected('$exception');

  static ReturnSuccessOrError<double, ComissaoError> _process(
    ComissaoParameters parameters,
  ) => parameters.valorTotal < 0
      ? const Failure(ValorInvalido('total value cannot be negative'))
      : Success(parameters.valorTotal * 0.05);
}
```

### 6. Call the usecase and handle the result

```dart
const usecase = GerarSalesReportUsecase(
  repository: SalesRepository(datasource: FakeSalesDatasource()),
  runInIsolate: true, // heavy processing runs on a background isolate
);

final result = await usecase(const SalesReportParameters(mes: 6, ano: 2026));
```

The `switch` is exhaustive **at both levels** — and takes no `default` branch:

```dart
final message = switch (result) {
  Success(:final value) => 'Revenue: ${value.faturamentoTotal}',
  Failure(:final error) => switch (error) {
    SalesSourceUnavailable() => 'Source unavailable: ${error.message}',
    EmptyPeriod() => 'No sales in the period',
    SalesUnexpected() => 'Unexpected error: ${error.message}',
  },
};
```

If a `SalesMalformedData` is added to the `sealed` set tomorrow, **this code stops
compiling** until the new case is handled. That is the difference between handling "the
error" and handling *the errors*.

### 7. Running on a background isolate

Both bases accept `runInIsolate: true`. When enabled, only `process` runs on an isolate
via `Isolate.run`; the fetch stays on the main isolate.

> **When to enable it:** `Isolate.run` has a fixed cost (spawn + input/output
> serialization) that scales with the data size. It pays off for **heavy** processing
> (parsing large lists, aggregations); for light transformations the overhead outweighs the
> gain. Use `monitorExecutionTime` to compare both paths.

### 8. Observability — `monitorExecutionTime` and the hook

With `monitorExecutionTime: true`, the total time is measured and handed to the
`onExecutionTimeMeasured` hook. The default implementation writes through `dart:developer`
(visible in DevTools); override it to plug in your logger or metrics collector — the
library imposes no logging dependency:

```dart
@override
void onExecutionTimeMeasured(Duration elapsed) =>
    myLogger.info('$runtimeType took ${elapsed.inMilliseconds}ms');
```

Disabled by default: zero cost in production.

### 9. Results without a value — `Unit` / `Nil`

For usecases that succeed without producing a value, use the `unit` (represents `void`) or
`nil` (represents `null`) singletons:

```dart
static ReturnSuccessOrError<Unit, LogoutError> _process(NoParams parameters) {
  // ... run the side effect ...
  return const Success(unit);
}
```

## Suggested feature hierarchy

```
lib/
  features/
    sales_report/
      datasources/
        fake_sales_datasource.dart
      repositories/
        sales_repository.dart
      domain/
        errors/
          sales_report_errors.dart
        model/
          sales_report.dart
        parameters/
          sales_report_parameters.dart
        usecase/
          gerar_sales_report_usecase.dart
  main.dart
```

## Migrating from v2 to v3

| v2 | v3 |
|----|----|
| `ReturnSuccessOrError<T>` | `ReturnSuccessOrError<TValue, TError>` |
| `SuccessReturn(success: v)` / `.result` | `Success(v)` / `.value` |
| `ErrorReturn(error: e)` / `.result` | `Failure(e)` / `.error` |
| `ParametersReturnResult` (required to expose `AppError error`) | `Parameters` (data only) |
| `NoParams(error: ...)` | `noParams` |
| `AppError` interface with `copyWith` | `AppError` base class with `message`, `toString`, `==` |
| `ErrorGeneric(message: "x")` | `ErrorGeneric("x")` |
| Datasource does `throw parameters.error` | Datasource lets the technical exception bubble up |
| Base appends `"Cod. 02-1"` to the message | `RepositoryBase.mapError` translates (mandatory) |
| Exception in process becomes `"Cod. IsolateCatch"` (isolate only) | `onUnexpected` translates (mandatory, both modes) |
| `UsecaseBaseCallData(datasource: ...)` | `UsecaseBaseCallData(repository: ...)` |
| `process` receives `ParametersReturnResult` (requires a cast) | `process` receives a typed `TParams` |
| `monitorExecutionTime` logs with `print` + `log` | `onExecutionTimeMeasured(Duration)` hook |

Suggested route: (1) create the feature's `sealed` error set; (2) take the `error` out of
the parameters; (3) extract the datasource's `try/catch` into a `RepositoryBase.mapError`;
(4) swap `datasource:` for `repository:` in the usecase and implement `onUnexpected`;
(5) update the consumer's `switch` to `Success`/`Failure` and cover every error.

## Example

The [`example/`](example/) directory holds a **pure Dart** (CLI) example:

- **`check_connection`** — the three complete layers, with a business error
  (`ConnectionOffline`, from `process`) and a technical one (`ConnectionUnavailable`, from
  `mapError`).
- **`fibonacci`** — a pure `UsecaseBase` running on an isolate, with typed parameters.
- **`sales_report`** — the **fetch → short-circuit → process** flow over 50k rows, four
  possible errors and an overridden `onExecutionTimeMeasured` hook.

Run it with `dart run bin/example.dart` and the tests with `dart test`.

## Environment

- Dart SDK `^3.12.0` (uses Dart 3 features: sealed classes, pattern matching, class
  modifiers and Dart 3.12 private named parameters).
- Depends only on `package:meta` (for `@protected`/`@immutable`) — no Flutter.
