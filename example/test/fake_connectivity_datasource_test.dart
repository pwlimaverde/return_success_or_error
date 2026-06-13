import 'package:return_success_or_error/return_success_or_error.dart';
import 'package:return_success_or_error_example/features/check_connection/datasources/fake_connectivity_datasource.dart';
import 'package:test/test.dart';

void main() {
  final params = NoParams(
    error: const ErrorGeneric(message: "connection error"),
  );

  test('online: true retorna true', () async {
    const datasource = FakeConnectivityDatasource(online: true);
    expect(await datasource(params), isTrue);
  });

  test('online: false retorna false', () async {
    const datasource = FakeConnectivityDatasource(online: false);
    expect(await datasource(params), isFalse);
  });

  test('shouldThrow lança o AppError dos parâmetros (enriquecido)', () async {
    const datasource = FakeConnectivityDatasource(shouldThrow: true);
    await expectLater(
      () => datasource(params),
      throwsA(
        isA<AppError>().having(
          (e) => e.message,
          'message',
          equals("simulated network failure"),
        ),
      ),
    );
  });
}
