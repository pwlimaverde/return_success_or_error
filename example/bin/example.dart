import 'package:return_success_or_error/return_success_or_error.dart';
import 'package:return_success_or_error_example/features/check_connection/datasources/fake_connectivity_datasource.dart';
import 'package:return_success_or_error_example/features/check_connection/domain/usecase/check_connection_usecase.dart';
import 'package:return_success_or_error_example/features/fibonacci/domain/parameters/fibonacci_parameters.dart';
import 'package:return_success_or_error_example/features/fibonacci/domain/usecase/fibonacci_usecase.dart';
import 'package:return_success_or_error_example/features/sales_report/datasources/fake_sales_datasource.dart';
import 'package:return_success_or_error_example/features/sales_report/domain/model/sales_report.dart';
import 'package:return_success_or_error_example/features/sales_report/domain/parameters/sales_report_parameters.dart';
import 'package:return_success_or_error_example/features/sales_report/domain/usecase/gerar_sales_report_usecase.dart';

Future<void> main() async {
  print("== return_success_or_error — pure Dart example ==\n");

  await _checkConnection();
  await _fibonacci();
  await _salesReport();
}

/// Demonstra um usecase que consome um datasource, nos três fluxos:
/// sucesso, erro de negócio (offline) e exceção capturada pela fase de fetch
/// da base.
Future<void> _checkConnection() async {
  print("--- CheckConnection (UsecaseBaseCallData) ---");

  // 1) Sucesso
  final online = CheckConnectionUsecase(
    datasource: const FakeConnectivityDatasource(online: true),
  );
  final r1 = await online(
    NoParams(error: const ErrorGeneric(message: "connection error")),
  );
  switch (r1) {
    case SuccessReturn<String>():
      print("ok  -> ${r1.result}");
    case ErrorReturn<String>():
      print("err -> ${r1.result.message}");
  }

  // 2) Erro de negócio (offline)
  final offline = CheckConnectionUsecase(
    datasource: const FakeConnectivityDatasource(online: false),
  );
  final r2 = await offline(
    NoParams(error: const ErrorGeneric(message: "connection error")),
  );
  switch (r2) {
    case SuccessReturn<String>():
      print("ok  -> ${r2.result}");
    case ErrorReturn<String>():
      print("err -> ${r2.result.message}");
  }

  // 3) Datasource lança exceção — capturada e enriquecida pela fase de fetch.
  final failing = CheckConnectionUsecase(
    datasource: const FakeConnectivityDatasource(shouldThrow: true),
  );
  final r3 = await failing(
    NoParams(error: const ErrorGeneric(message: "connection error")),
  );
  switch (r3) {
    case SuccessReturn<String>():
      print("ok  -> ${r3.result}");
    case ErrorReturn<String>():
      print("err -> ${r3.result.message}");
  }

  print("");
}

/// Demonstra um usecase de regra de negócio pura rodando em isolate.
Future<void> _fibonacci() async {
  print("--- Fibonacci (UsecaseBase com runInIsolate: true) ---");

  final usecase = const FibonacciUsecase(runInIsolate: true);
  final result = await usecase(
    const FibonacciParameters(
      n: 30,
      error: ErrorGeneric(message: "fibonacci error"),
    ),
  );

  switch (result) {
    case SuccessReturn<int>():
      print("ok  -> fib(30) = ${result.result}");
    case ErrorReturn<int>():
      print("err -> ${result.result.message}");
  }

  print("");
}

/// Demonstra o fluxo fetch → process: o datasource devolve 50k linhas cruas de
/// venda (fase 1, isolate principal) e o usecase processa o objeto
/// [SalesReport] (fase 3, em isolate). Compara as duas formas via
/// `monitorExecutionTime`.
Future<void> _salesReport() async {
  print(
    "--- SalesReport (UsecaseBaseCallData com fetch → process em isolate) ---",
  );

  const datasource = FakeSalesDatasource(linhas: 50000);
  const params = SalesReportParameters(
    mes: 6,
    ano: 2026,
    error: ErrorGeneric(message: "Falha ao gerar relatório de vendas"),
  );

  // Forma A — processa no event loop principal (mais rápido, mas bloquearia a UI).
  final direto = GerarSalesReportUsecase(
    datasource: datasource,
    runInIsolate: false,
    monitorExecutionTime: true,
  );
  await direto(params);

  // Forma B — processa em isolate (UI fluida; loga "(Isolate)").
  final isolado = GerarSalesReportUsecase(
    datasource: datasource,
    runInIsolate: true,
    monitorExecutionTime: true,
  );
  final result = await isolado(params);

  switch (result) {
    case SuccessReturn<SalesReport>():
      final report = result.result;
      print(
        "ok  -> faturamento: R\$ ${report.faturamentoTotal.toStringAsFixed(2)}",
      );
      print(
        "       ticket médio: R\$ ${report.ticketMedio.toStringAsFixed(2)}",
      );
      print("       mais vendido: ${report.produtoMaisVendido}");
    case ErrorReturn<SalesReport>():
      print("err -> ${result.result.message}");
  }
}
