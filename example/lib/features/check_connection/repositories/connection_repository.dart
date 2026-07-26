import 'dart:async';

import 'package:return_success_or_error/return_success_or_error.dart';

import '../domain/errors/connection_errors.dart';

/// A **fronteira** da feature: chama o datasource e traduz toda exceção técnica
/// em um dos [ConnectionError] previstos.
///
/// A partir daqui, o domínio só vê `Success | Failure` — nenhuma exceção de
/// infraestrutura atravessa esta linha.
final class ConnectionRepository
    extends RepositoryBase<bool, NoParams, ConnectionError> {
  const ConnectionRepository({required super.datasource});

  @override
  ConnectionError mapError(
    Object exception,
    StackTrace stackTrace,
    NoParams parameters,
  ) => switch (exception) {
    TimeoutException() => ConnectionUnavailable(
      'Não foi possível verificar a conexão: $exception',
    ),
    _ => ConnectionUnexpected('Falha inesperada: $exception'),
  };
}
