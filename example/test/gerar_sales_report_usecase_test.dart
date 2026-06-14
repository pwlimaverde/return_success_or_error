import 'package:return_success_or_error/return_success_or_error.dart';
import 'package:return_success_or_error_example/features/sales_report/datasources/fake_sales_datasource.dart';
import 'package:return_success_or_error_example/features/sales_report/domain/model/sales_report.dart';
import 'package:return_success_or_error_example/features/sales_report/domain/parameters/sales_report_parameters.dart';
import 'package:return_success_or_error_example/features/sales_report/domain/usecase/gerar_sales_report_usecase.dart';
import 'package:test/test.dart';

void main() {
  const params = SalesReportParameters(
    mes: 6,
    ano: 2026,
    error: ErrorGeneric(message: "Falha ao gerar relatório de vendas"),
  );

  test(
    'processa as linhas cruas no objeto SalesReport (caminho direto)',
    () async {
      final usecase = GerarSalesReportUsecase(
        datasource: const FakeSalesDatasource(linhas: 1000),
      );

      final data = await usecase(params);

      switch (data) {
        case SuccessReturn<SalesReport>():
          final report = data.result;
          // 1000 linhas, quantidade = (i % 5) + 1  → soma conhecida.
          expect(report.totalItens, equals(3000));
          expect(report.faturamentoTotal, greaterThan(0));
          expect(report.ticketMedio, equals(report.faturamentoTotal / 1000));
          expect(report.produtoMaisVendido, startsWith('Produto '));
        case ErrorReturn<SalesReport>():
          fail('Esperava SuccessReturn, veio: ${data.result.message}');
      }
    },
  );

  test(
    'o caminho isolate produz o MESMO resultado do caminho direto',
    () async {
      final direto = GerarSalesReportUsecase(
        datasource: const FakeSalesDatasource(linhas: 5000),
        runInIsolate: false,
        monitorExecutionTime: true,
      );
      final isolado = GerarSalesReportUsecase(
        datasource: const FakeSalesDatasource(linhas: 5000),
        runInIsolate: true,
        monitorExecutionTime: true,
      );

      final rDireto = await direto(params);
      final rIsolado = await isolado(params);

      final a = switch (rDireto) {
        SuccessReturn<SalesReport>() => rDireto.result,
        ErrorReturn<SalesReport>() => fail('direto: ${rDireto.result.message}'),
      };
      final b = switch (rIsolado) {
        SuccessReturn<SalesReport>() => rIsolado.result,
        ErrorReturn<SalesReport>() => fail(
          'isolado: ${rIsolado.result.message}',
        ),
      };

      expect(a.totalItens, equals(b.totalItens));
      expect(a.faturamentoTotal, equals(b.faturamentoTotal));
      expect(a.ticketMedio, equals(b.ticketMedio));
      expect(a.produtoMaisVendido, equals(b.produtoMaisVendido));
    },
  );

  test('falha do datasource é enriquecida com Cod. 02-1 (fetch fora do '
      'isolate)', () async {
    final usecase = GerarSalesReportUsecase(
      datasource: const FakeSalesDatasource(shouldThrow: true),
      runInIsolate: true,
    );

    final data = await usecase(params);

    switch (data) {
      case SuccessReturn<SalesReport>():
        fail('Esperava ErrorReturn');
      case ErrorReturn<SalesReport>():
        expect(data.result.message, contains('Cod. 02-1'));
        expect(data.result.message, contains('simulated database failure'));
    }
  });

  test('período sem vendas retorna erro de negócio', () async {
    final usecase = GerarSalesReportUsecase(
      datasource: const FakeSalesDatasource(linhas: 0),
    );

    final data = await usecase(params);

    switch (data) {
      case SuccessReturn<SalesReport>():
        fail('Esperava ErrorReturn');
      case ErrorReturn<SalesReport>():
        expect(data.result.message, contains('Sem vendas no período'));
    }
  });

  test(
    'comparativo de tempo com monitorExecutionTime (direto vs isolate)',
    () async {
      // Loga "Execution Time ... (Direct): Xms" e "... (Isolate): Yms" via
      // dart:developer — útil para avaliar qual caminho compensa por volume.
      final direto = GerarSalesReportUsecase(
        datasource: const FakeSalesDatasource(linhas: 50000),
        runInIsolate: false,
        monitorExecutionTime: true,
      );
      final isolado = GerarSalesReportUsecase(
        datasource: const FakeSalesDatasource(linhas: 50000),
        runInIsolate: true,
        monitorExecutionTime: true,
      );

      final rDireto = await direto(params);
      final rIsolado = await isolado(params);

      expect(rDireto, isA<SuccessReturn<SalesReport>>());
      expect(rIsolado, isA<SuccessReturn<SalesReport>>());
    },
  );
}
