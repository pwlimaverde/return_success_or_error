import 'package:return_success_or_error/return_success_or_error.dart';

/// Parâmetros do relatório de vendas: o período a consultar e o [AppError]
/// retornado em caso de falha.
///
/// Imutável e *sendable* — pode ser reexecutado com segurança e cruzar a
/// fronteira de um [Isolate].
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
