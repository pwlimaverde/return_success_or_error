import 'package:return_success_or_error/return_success_or_error.dart';
import 'package:return_success_or_error_example/features/check_connection/datasources/fake_connectivity_datasource.dart';
import 'package:return_success_or_error_example/features/check_connection/domain/errors/connection_errors.dart';
import 'package:return_success_or_error_example/features/check_connection/domain/usecase/check_connection_usecase.dart';
import 'package:return_success_or_error_example/features/check_connection/repositories/connection_repository.dart';
import 'package:test/test.dart';

CheckConnectionUsecase usecaseCom(FakeConnectivityDatasource datasource) =>
    CheckConnectionUsecase(
      repository: ConnectionRepository(datasource: datasource),
    );

void main() {
  group('CheckConnectionUsecase', () {
    test('Deve retornar um success com "You are connected"', () async {
      final result = await usecaseCom(
        const FakeConnectivityDatasource(online: true),
      )(noParams);

      switch (result) {
        case Success(:final value):
          expect(value, equals('You are connected'));
        case Failure():
          fail('Esperava Success');
      }
    });

    test('Deve retornar ConnectionOffline quando não há conexão', () async {
      final result = await usecaseCom(
        const FakeConnectivityDatasource(online: false),
      )(noParams);

      switch (result) {
        case Success():
          fail('Esperava Failure');
        case Failure(:final error):
          // Erro de NEGÓCIO: nasce no process, não no mapError.
          expect(error, isA<ConnectionOffline>());
          expect(error.message, equals('You are offline'));
      }
    });

    test('Deve retornar ConnectionUnavailable quando a fonte falha', () async {
      final result = await usecaseCom(
        const FakeConnectivityDatasource(shouldThrow: true),
      )(noParams);

      switch (result) {
        case Success():
          fail('Esperava Failure');
        case Failure(:final error):
          // Erro TÉCNICO: traduzido pelo mapError do repositório e
          // curto-circuitado antes do process.
          expect(error, isA<ConnectionUnavailable>());
      }
    });

    test(
      'O consumo cobre todos os erros da feature sem braço default',
      () async {
        final result = await usecaseCom(
          const FakeConnectivityDatasource(online: false),
        )(noParams);

        final descricao = switch (result) {
          Success(:final value) => value,
          Failure(:final error) => switch (error) {
            ConnectionOffline() => 'offline',
            ConnectionUnavailable() => 'indisponivel',
            ConnectionUnexpected() => 'inesperado',
          },
        };

        expect(descricao, equals('offline'));
      },
    );
  });
}
