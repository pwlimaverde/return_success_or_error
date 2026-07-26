import 'dart:async';

import 'package:return_success_or_error/return_success_or_error.dart';

import '../domain/errors/sales_report_errors.dart';
import '../domain/parameters/sales_report_parameters.dart';

/// A fronteira da feature de vendas: traduz a exceção técnica da fonte em um
/// erro do conjunto fechado, usando os [SalesReportParameters] como contexto.
final class SalesRepository
    extends
        RepositoryBase<
          List<Map<String, dynamic>>,
          SalesReportParameters,
          SalesReportError
        > {
  const SalesRepository({required super.datasource});

  @override
  SalesReportError mapError(
    Object exception,
    StackTrace stackTrace,
    SalesReportParameters parameters,
  ) {
    // O `stackTrace` chega aqui porque, em Dart, ele não viaja dentro da
    // exceção. Este exemplo não o usa, mas é onde entraria o report para o
    // Sentry/Crashlytics — a fronteira é o último ponto que conhece a origem
    // técnica da falha.
    final periodo = '${parameters.mes}/${parameters.ano}';

    return switch (exception) {
      TimeoutException() => SalesSourceUnavailable(
        'Fonte de vendas indisponível para $periodo: $exception',
      ),
      FormatException() => SalesMalformedData(
        'Dados inválidos em $periodo: $exception',
      ),
      _ => SalesUnexpected('Falha inesperada em $periodo: $exception'),
    };
  }
}
