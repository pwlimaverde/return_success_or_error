import 'package:return_success_or_error/return_success_or_error.dart';

import '../errors/sales_report_errors.dart';
import '../model/sales_report.dart';
import '../parameters/sales_report_parameters.dart';

/// Gera um [SalesReport] a partir das linhas cruas devolvidas pelo repositório.
///
/// A base faz o fetch (no isolate principal) e, em caso de sucesso, chama o
/// [process] com as linhas já carregadas. Construa com `runInIsolate: true` para
/// que o parsing/agregação pesado rode em um isolate de background, deixando o
/// event loop (e a UI) livre.
final class GerarSalesReportUsecase
    extends
        UsecaseBaseCallData<
          SalesReport,
          List<Map<String, dynamic>>,
          SalesReportParameters,
          SalesReportError
        > {
  const GerarSalesReportUsecase({
    required super.repository,
    super.runInIsolate,
    super.monitorExecutionTime,
  });

  @override
  ProcessData<
    SalesReport,
    List<Map<String, dynamic>>,
    SalesReportParameters,
    SalesReportError
  >
  get process => _process;

  @override
  SalesReportError onUnexpected(Object exception, StackTrace stackTrace) =>
      SalesUnexpected('Falha ao processar o relatório: $exception');

  /// Demonstra o hook de observabilidade: a implementação padrão escreve via
  /// `dart:developer` (visível no DevTools); aqui o tempo vai para o console,
  /// que é o que este exemplo de CLI precisa. Em um app real, este é o ponto de
  /// integração com o seu logger ou coletor de métricas.
  @override
  void onExecutionTimeMeasured(Duration elapsed) {
    final modo = runInIsolate ? 'Isolate' : 'Direct';
    print('       [$modo] ${elapsed.inMilliseconds}ms');
  }

  /// Função **estática** (não captura `this` nem o repositório): faz o parsing e
  /// a agregação das linhas cruas. É esta função que roda no isolate quando
  /// `runInIsolate: true`.
  static ReturnSuccessOrError<SalesReport, SalesReportError> _process(
    List<Map<String, dynamic>> linhas,
    SalesReportParameters parameters,
  ) {
    if (linhas.isEmpty) {
      return Failure(
        EmptyPeriod(
          'Sem vendas no período',
          mes: parameters.mes,
          ano: parameters.ano,
        ),
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

    return Success(
      SalesReport(
        totalItens: itens,
        faturamentoTotal: faturamento,
        ticketMedio: faturamento / linhas.length,
        produtoMaisVendido: maisVendido,
      ),
    );
  }
}
