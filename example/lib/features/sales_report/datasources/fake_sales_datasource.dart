import 'dart:async';

import 'package:return_success_or_error/return_success_or_error.dart';

import '../domain/parameters/sales_report_parameters.dart';

/// Datasource que simula um banco devolvendo as linhas **cruas** de venda.
///
/// O tipo cru é `List<Map<String, dynamic>>` — exatamente como viria de um
/// driver de banco. O datasource só faz o I/O (assíncrono, não bloqueia o event
/// loop) e devolve os dados sem processá-los; o parsing/agregação pesado fica a
/// cargo do `process` do usecase, que pode rodar em isolate.
///
/// Sem `try/catch`: a exceção técnica sobe crua, com todo o seu contexto, para o
/// `mapError` do repositório traduzir.
final class FakeSalesDatasource
    implements Datasource<List<Map<String, dynamic>>, SalesReportParameters> {
  /// Quantidade de linhas a gerar (simula o volume do período).
  final int linhas;

  /// Se `true`, simula uma falha de conexão/consulta.
  final bool shouldThrow;

  /// Se `true`, devolve linhas com o **tipo errado** em `quantidade` (`String`
  /// no lugar de `int`). O I/O tem sucesso, mas o `process` quebra ao fazer o
  /// cast — é assim que o exemplo exercita o `onUnexpected`: um bug, não uma
  /// falha prevista.
  final bool linhasCorrompidas;

  const FakeSalesDatasource({
    this.linhas = 50000,
    this.shouldThrow = false,
    this.linhasCorrompidas = false,
  });

  @override
  Future<List<Map<String, dynamic>>> call(
    SalesReportParameters parameters,
  ) async {
    // Simula latência de rede/banco — I/O async, NÃO bloqueia o event loop.
    await Future<void>.delayed(const Duration(milliseconds: 300));

    if (shouldThrow) {
      throw TimeoutException('simulated database failure');
    }

    // Linhas cruas, como viriam do banco (serializáveis).
    return List.generate(
      linhas,
      (i) => {
        'id': 'venda_$i',
        'produto': 'Produto ${i % 20}',
        'quantidade': linhasCorrompidas ? 'dois' : (i % 5) + 1,
        'valor_unitario': 9.90 + (i % 50),
      },
    );
  }
}
