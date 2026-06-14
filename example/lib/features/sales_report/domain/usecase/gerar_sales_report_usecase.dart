import 'package:return_success_or_error/return_success_or_error.dart';

import '../model/sales_report.dart';

/// Gera um [SalesReport] a partir das linhas cruas devolvidas pelo datasource.
///
/// Estende [UsecaseBaseCallData]: `SalesReport` é o tipo final do usecase e
/// `List<Map<String, dynamic>>` é o tipo cru do datasource. A base faz o fetch
/// (no isolate principal) e, em caso de sucesso, chama [process] com as linhas
/// já carregadas. Construa com `runInIsolate: true` para que o parsing/agregação
/// pesado rode em um isolate de background, deixando o event loop (e a UI)
/// livre.
final class GerarSalesReportUsecase
    extends UsecaseBaseCallData<SalesReport, List<Map<String, dynamic>>> {
  GerarSalesReportUsecase({
    required super.datasource,
    super.runInIsolate,
    super.monitorExecutionTime,
  });

  @override
  ProcessData<SalesReport, List<Map<String, dynamic>>> get process => _process;

  /// Função **estática** (não captura `this` nem o datasource): faz o parsing e
  /// a agregação das linhas cruas. É esta função que roda no isolate quando
  /// `runInIsolate: true`.
  static ReturnSuccessOrError<SalesReport> _process(
    List<Map<String, dynamic>> linhas,
    ParametersReturnResult parameters,
  ) {
    if (linhas.isEmpty) {
      return ErrorReturn(
        error: parameters.error.copyWith(message: "Sem vendas no período"),
      );
    }

    // CPU pesada: parse + agregação de todas as linhas.
    var faturamento = 0.0;
    var itens = 0;
    final porProduto = <String, double>{};

    for (final row in linhas) {
      final quantidade = row['quantidade'] as int;
      final total = quantidade * (row['valor_unitario'] as num).toDouble();
      faturamento += total;
      itens += quantidade;
      porProduto.update(
        row['produto'] as String,
        (acc) => acc + total,
        ifAbsent: () => total,
      );
    }

    final maisVendido = porProduto.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;

    return SuccessReturn(
      success: SalesReport(
        totalItens: itens,
        faturamentoTotal: faturamento,
        ticketMedio: faturamento / linhas.length,
        produtoMaisVendido: maisVendido,
      ),
    );
  }
}
