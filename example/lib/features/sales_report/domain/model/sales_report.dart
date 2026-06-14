/// Objeto de domínio processado a partir das linhas cruas de venda.
///
/// Imutável e *sendable* (só campos primitivos), então pode atravessar a
/// fronteira de um [Isolate] sem problemas.
final class SalesReport {
  final int totalItens;
  final double faturamentoTotal;
  final double ticketMedio;
  final String produtoMaisVendido;

  const SalesReport({
    required this.totalItens,
    required this.faturamentoTotal,
    required this.ticketMedio,
    required this.produtoMaisVendido,
  });

  @override
  String toString() =>
      'SalesReport(itens: $totalItens, faturamento: '
      '${faturamentoTotal.toStringAsFixed(2)}, ticketMedio: '
      '${ticketMedio.toStringAsFixed(2)}, maisVendido: $produtoMaisVendido)';
}
