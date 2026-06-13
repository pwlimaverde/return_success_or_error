library;

/// Base classes for the feature's business rule.
///
/// [UsecaseBase] runs a pure business rule; [UsecaseBaseCallData] consumes a
/// [Datasource] and bridges to it through `resultDatasource`.
export 'src/bases/usecase_base.dart';

/// The sealed result type and its cases.
///
/// [ReturnSuccessOrError] stores either a [SuccessReturn] (the success value) or
/// an [ErrorReturn] (an [AppError]). Also exposes the `Unit`/`Nil` singletons.
export 'src/core/return_success_or_error.dart';

/// Auxiliary singleton that standardizes the initialization of basic services
/// and their dependencies.
export 'src/core/service.dart';

/// The external-call abstraction.
///
/// A [Datasource] queries the external call and must return the predefined data
/// type, or `throw` the [AppError] carried by the parameters (an [Exception]).
export 'src/interfaces/datasource.dart';

/// The immutable error contract and its default implementation.
///
/// Implementations of [AppError] expose a `message` getter and produce enriched
/// copies through `copyWith` (errors are immutable).
export 'src/interfaces/errors.dart';

/// The call-parameters abstraction.
///
/// Implementations of [ParametersReturnResult] carry the data required by the
/// datasource and must expose the [AppError] returned on failure.
export 'src/interfaces/parameters.dart';
