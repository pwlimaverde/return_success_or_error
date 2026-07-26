import 'package:return_success_or_error/return_success_or_error.dart';

/// Parâmetros do relatório de vendas: o período a consultar. **Só dados.**
///
/// Imutável e *sendable* — pode ser reexecutado com segurança e cruzar a
/// fronteira de um [Isolate].
final class SalesReportParameters extends Parameters {
  final int mes;
  final int ano;

  const SalesReportParameters({required this.mes, required this.ano});
}
