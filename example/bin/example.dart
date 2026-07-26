import 'package:return_success_or_error/return_success_or_error.dart';
import 'package:return_success_or_error_example/features/check_connection/datasources/fake_connectivity_datasource.dart';
import 'package:return_success_or_error_example/features/check_connection/domain/errors/connection_errors.dart';
import 'package:return_success_or_error_example/features/check_connection/domain/usecase/check_connection_usecase.dart';
import 'package:return_success_or_error_example/features/check_connection/repositories/connection_repository.dart';
import 'package:return_success_or_error_example/features/fibonacci/domain/errors/fibonacci_errors.dart';
import 'package:return_success_or_error_example/features/fibonacci/domain/parameters/fibonacci_parameters.dart';
import 'package:return_success_or_error_example/features/fibonacci/domain/usecase/fibonacci_usecase.dart';
import 'package:return_success_or_error_example/features/sales_report/datasources/fake_sales_datasource.dart';
import 'package:return_success_or_error_example/features/sales_report/domain/errors/sales_report_errors.dart';
import 'package:return_success_or_error_example/features/sales_report/domain/parameters/sales_report_parameters.dart';
import 'package:return_success_or_error_example/features/sales_report/domain/usecase/gerar_sales_report_usecase.dart';
import 'package:return_success_or_error_example/features/sales_report/repositories/sales_repository.dart';

Future<void> main() async {
  print('== return_success_or_error — pure Dart example ==\n');

  await _checkConnection();
  await _fibonacci();
  await _salesReport();
}

/// Demonstra as três camadas (Datasource → Repository → Usecase) e os três
/// fluxos: sucesso, erro de negócio (offline) e falha técnica traduzida pelo
/// `mapError` do repositório.
Future<void> _checkConnection() async {
  print('--- CheckConnection (três camadas) ---');

  Future<void> executar(
    String rotulo,
    FakeConnectivityDatasource datasource,
  ) async {
    // Composição: o datasource entra no repositório, o repositório no usecase.
    final usecase = CheckConnectionUsecase(
      repository: ConnectionRepository(datasource: datasource),
    );

    final result = await usecase(noParams);

    // Switch exaustivo nos DOIS níveis: sucesso/falha e, dentro da falha, cada
    // erro previsto pela feature — sem braço `default`.
    final saida = switch (result) {
      Success(:final value) => 'ok  -> $value',
      Failure(:final error) => switch (error) {
        ConnectionOffline() => 'off -> ${error.message}',
        ConnectionUnavailable() => 'err -> ${error.message}',
        ConnectionUnexpected() => 'bug -> ${error.message}',
      },
    };

    print('$rotulo $saida');
  }

  await executar('online   ', const FakeConnectivityDatasource(online: true));
  await executar('offline  ', const FakeConnectivityDatasource(online: false));
  await executar(
    'timeout  ',
    const FakeConnectivityDatasource(shouldThrow: true),
  );

  print('');
}

/// Demonstra um usecase de regra de negócio pura rodando em isolate, com os
/// parâmetros já tipados no `process` (sem cast).
Future<void> _fibonacci() async {
  print('--- Fibonacci (UsecaseBase com runInIsolate: true) ---');

  const usecase = FibonacciUsecase(runInIsolate: true);

  for (final n in [30, -1]) {
    final result = await usecase(FibonacciParameters(n: n));

    print(switch (result) {
      Success(:final value) => 'ok  -> fib($n) = $value',
      Failure(:final error) => switch (error) {
        NegativeIndex() => 'err -> ${error.message}',
        FibonacciUnexpected() => 'bug -> ${error.message}',
      },
    });
  }

  print('');
}

/// Demonstra o fluxo fetch → curto-circuito → process: o repositório devolve
/// 50k linhas cruas de venda (fase 1, isolate principal) e o usecase processa o
/// [SalesReport] (fase 3, em isolate). Compara as duas formas pelo hook
/// `onExecutionTimeMeasured`.
Future<void> _salesReport() async {
  print('--- SalesReport (fetch → process em isolate) ---');

  const repository = SalesRepository(
    datasource: FakeSalesDatasource(linhas: 50000),
  );
  const params = SalesReportParameters(mes: 6, ano: 2026);

  // Forma A — processa no event loop principal (mais rápido, mas bloquearia a UI).
  const direto = GerarSalesReportUsecase(
    repository: repository,
    monitorExecutionTime: true,
  );
  await direto(params);

  // Forma B — processa em isolate (UI fluida).
  const isolado = GerarSalesReportUsecase(
    repository: repository,
    runInIsolate: true,
    monitorExecutionTime: true,
  );
  final result = await isolado(params);

  switch (result) {
    case Success(:final value):
      print(
        'ok  -> faturamento: R\$ ${value.faturamentoTotal.toStringAsFixed(2)}',
      );
      print('       ticket médio: R\$ ${value.ticketMedio.toStringAsFixed(2)}');
      print('       mais vendido: ${value.produtoMaisVendido}');
    case Failure(:final error):
      print(switch (error) {
        SalesSourceUnavailable() =>
          'err -> fonte indisponível: ${error.message}',
        SalesMalformedData() => 'err -> dados inválidos: ${error.message}',
        EmptyPeriod() => 'err -> sem vendas em ${error.mes}/${error.ano}',
        SalesUnexpected() => 'bug -> ${error.message}',
      });
  }

  // Falha técnica da fonte: traduzida pelo `mapError` do repositório e
  // curto-circuitada — o `process` nem chega a ser chamado.
  const falhaTecnica = GerarSalesReportUsecase(
    repository: SalesRepository(
      datasource: FakeSalesDatasource(shouldThrow: true),
    ),
  );
  if (await falhaTecnica(params) case Failure(:final error)) {
    print('err -> ${error.runtimeType}: ${error.message}');
  }

  // Bug no `process`: a fonte responde, mas com dados de tipo errado, e o cast
  // explode. O `onUnexpected` converte em um erro previsto da feature — o
  // usecase não propaga a exceção ao chamador.
  const comBug = GerarSalesReportUsecase(
    repository: SalesRepository(
      datasource: FakeSalesDatasource(linhas: 10, linhasCorrompidas: true),
    ),
  );
  if (await comBug(params) case Failure(:final error)) {
    print('bug -> ${error.runtimeType}: ${error.message}');
  }
}
