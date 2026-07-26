import 'dart:async';

import 'package:return_success_or_error/return_success_or_error.dart';
import 'package:return_success_or_error_example/features/check_connection/datasources/fake_connectivity_datasource.dart';
import 'package:return_success_or_error_example/features/check_connection/domain/errors/connection_errors.dart';
import 'package:return_success_or_error_example/features/check_connection/repositories/connection_repository.dart';
import 'package:test/test.dart';

void main() {
  group('FakeConnectivityDatasource', () {
    test('Deve retornar o bool cru', () async {
      expect(
        await const FakeConnectivityDatasource(online: true)(noParams),
        isTrue,
      );
      expect(
        await const FakeConnectivityDatasource(online: false)(noParams),
        isFalse,
      );
    });

    test('Deve propagar a exceção técnica sem traduzi-la', () async {
      // `expectLater` + await: a falha é assíncrona, e sem aguardar o matcher o
      // teste terminaria antes de verificar o throw.
      await expectLater(
        const FakeConnectivityDatasource(shouldThrow: true)(noParams),
        throwsA(isA<TimeoutException>()),
      );
    });
  });

  group('ConnectionRepository', () {
    test('Deve retornar success com o dado bruto', () async {
      const repository = ConnectionRepository(
        datasource: FakeConnectivityDatasource(online: true),
      );

      final result = await repository(noParams);

      expect(result, equals(const Success<bool, ConnectionError>(true)));
    });

    test('Deve traduzir o timeout em ConnectionUnavailable', () async {
      const repository = ConnectionRepository(
        datasource: FakeConnectivityDatasource(shouldThrow: true),
      );

      final result = await repository(noParams);

      switch (result) {
        case Success():
          fail('Esperava Failure');
        case Failure(:final error):
          expect(error, isA<ConnectionUnavailable>());
          expect(error.message, contains('simulated network failure'));
      }
    });
  });
}
