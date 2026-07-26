import 'package:return_success_or_error/return_success_or_error.dart';

/// Conjunto **fechado** dos erros da feature de relatório de vendas.
///
/// Note a divisão de responsabilidades: [SalesSourceUnavailable] e
/// [SalesMalformedData] nascem no `mapError` do repositório (falhas técnicas
/// traduzidas), [EmptyPeriod] nasce no `process` (regra de negócio) e
/// [SalesUnexpected] no `onUnexpected` (bug). Todos convergem para o mesmo
/// `switch` exaustivo no consumidor.
sealed class SalesReportError extends AppError {
  const SalesReportError(super.message);
}

/// A fonte não respondeu (timeout, banco fora do ar).
final class SalesSourceUnavailable extends SalesReportError {
  const SalesSourceUnavailable(super.message);
}

/// A fonte respondeu, mas com dados que não é possível interpretar.
final class SalesMalformedData extends SalesReportError {
  const SalesMalformedData(super.message);
}

/// Erro de negócio: não houve vendas no período consultado.
final class EmptyPeriod extends SalesReportError {
  final int mes;
  final int ano;

  const EmptyPeriod(super.message, {required this.mes, required this.ano});

  // Campos adicionais entram na igualdade — a herdada compara só a message.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmptyPeriod &&
          other.message == message &&
          other.mes == mes &&
          other.ano == ano;

  @override
  int get hashCode => Object.hash(message, mes, ano);
}

/// O inesperado — alvo do braço `default` do `mapError` e do `onUnexpected`.
final class SalesUnexpected extends SalesReportError {
  const SalesUnexpected(super.message);
}
