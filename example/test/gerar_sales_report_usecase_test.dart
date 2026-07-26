import 'package:return_success_or_error/return_success_or_error.dart';
import 'package:return_success_or_error_example/features/sales_report/datasources/fake_sales_datasource.dart';
import 'package:return_success_or_error_example/features/sales_report/domain/errors/sales_report_errors.dart';
import 'package:return_success_or_error_example/features/sales_report/domain/model/sales_report.dart';
import 'package:return_success_or_error_example/features/sales_report/domain/parameters/sales_report_parameters.dart';
import 'package:return_success_or_error_example/features/sales_report/domain/usecase/gerar_sales_report_usecase.dart';
import 'package:return_success_or_error_example/features/sales_report/repositories/sales_repository.dart';
import 'package:test/test.dart';

const parameters = SalesReportParameters(mes: 6, ano: 2026);

GerarSalesReportUsecase usecaseCom(
  FakeSalesDatasource datasource, {
  bool runInIsolate = false,
}) => GerarSalesReportUsecase(
  repository: SalesRepository(datasource: datasource),
  runInIsolate: runInIsolate,
);

SalesReport esperaSucesso(
  ReturnSuccessOrError<SalesReport, SalesReportError> result,
) => switch (result) {
  Success(:final value) => value,
  Failure(:final error) => fail('Esperava Success, veio $error'),
};

void main() {
  group('GerarSalesReportUsecase', () {
    test('Deve processar as linhas cruas em um SalesReport', () async {
      final report = esperaSucesso(
        await usecaseCom(const FakeSalesDatasource(linhas: 1000))(parameters),
      );

      expect(report.totalItens, greaterThan(0));
      expect(report.faturamentoTotal, greaterThan(0));
      expect(report.ticketMedio, greaterThan(0));
      expect(report.produtoMaisVendido, startsWith('Produto '));
    });

    test(
      'Deve produzir o mesmo relatório no isolate e no caminho direto',
      () async {
        final direto = esperaSucesso(
          await usecaseCom(const FakeSalesDatasource(linhas: 5000))(parameters),
        );
        final isolado = esperaSucesso(
          await usecaseCom(
            const FakeSalesDatasource(linhas: 5000),
            runInIsolate: true,
          )(parameters),
        );

        expect(isolado.totalItens, equals(direto.totalItens));
        expect(isolado.faturamentoTotal, equals(direto.faturamentoTotal));
        expect(isolado.produtoMaisVendido, equals(direto.produtoMaisVendido));
      },
    );

    test('Deve retornar EmptyPeriod quando não há vendas no período', () async {
      final result = await usecaseCom(const FakeSalesDatasource(linhas: 0))(
        parameters,
      );

      switch (result) {
        case Success():
          fail('Esperava Failure');
        case Failure(:final error):
          // Erro de NEGÓCIO, com o contexto do período no próprio erro.
          expect(error, isA<EmptyPeriod>());
          expect((error as EmptyPeriod).mes, equals(6));
          expect(error.ano, equals(2026));
      }
    });

    test(
      'Falha da fonte vira SalesSourceUnavailable e curto-circuita',
      () async {
        final result = await usecaseCom(
          const FakeSalesDatasource(shouldThrow: true),
        )(parameters);

        switch (result) {
          case Success():
            fail('Esperava Failure');
          case Failure(:final error):
            expect(error, isA<SalesSourceUnavailable>());
            expect(error.message, contains('6/2026'));
        }
      },
    );

    test('Bug no process vira SalesUnexpected via onUnexpected', () async {
      // O fetch tem sucesso, mas os dados vêm com o tipo errado: o cast dentro
      // do process explode. Nada propaga ao chamador.
      final result = await usecaseCom(
        const FakeSalesDatasource(linhas: 10, linhasCorrompidas: true),
      )(parameters);

      switch (result) {
        case Success():
          fail('Esperava Failure');
        case Failure(:final error):
          expect(error, isA<SalesUnexpected>());
      }
    });

    test('Bug no process também não propaga em isolate', () async {
      final result = await usecaseCom(
        const FakeSalesDatasource(linhas: 10, linhasCorrompidas: true),
        runInIsolate: true,
      )(parameters);

      expect(result, isA<Failure<SalesReport, SalesReportError>>());
    });

    test(
      'O consumo cobre todos os erros da feature sem braço default',
      () async {
        final result = await usecaseCom(const FakeSalesDatasource(linhas: 0))(
          parameters,
        );

        final descricao = switch (result) {
          Success() => 'ok',
          Failure(:final error) => switch (error) {
            SalesSourceUnavailable() => 'indisponivel',
            SalesMalformedData() => 'invalido',
            EmptyPeriod() => 'vazio',
            SalesUnexpected() => 'inesperado',
          },
        };

        expect(descricao, equals('vazio'));
      },
    );
  });
}
