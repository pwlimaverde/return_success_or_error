import 'package:return_success_or_error/return_success_or_error.dart';
import 'package:return_success_or_error_example/features/check_connection/datasources/fake_connectivity_datasource.dart';
import 'package:return_success_or_error_example/features/check_connection/domain/usecase/check_connection_usecase.dart';
import 'package:test/test.dart';

void main() {
  final params = NoParams(
    error: const ErrorGeneric(message: "connection error"),
  );

  test('online -> success "You are connected"', () async {
    final usecase = CheckConnectionUsecase(
      datasource: const FakeConnectivityDatasource(online: true),
    );
    final data = await usecase(params);

    switch (data) {
      case SuccessReturn<String>():
        expect(data.result, equals("You are connected"));
      case ErrorReturn<String>():
        fail('Esperava SuccessReturn');
    }
  });

  test('offline -> erro de negócio "You are offline"', () async {
    final usecase = CheckConnectionUsecase(
      datasource: const FakeConnectivityDatasource(online: false),
    );
    final data = await usecase(params);

    switch (data) {
      case SuccessReturn<String>():
        fail('Esperava ErrorReturn');
      case ErrorReturn<String>():
        expect(data.result.message, equals("You are offline"));
    }
  });

  test('exceção do datasource -> error enriquecido com Cod. 02-1', () async {
    final usecase = CheckConnectionUsecase(
      datasource: const FakeConnectivityDatasource(shouldThrow: true),
    );
    final data = await usecase(params);

    switch (data) {
      case SuccessReturn<String>():
        fail('Esperava ErrorReturn');
      case ErrorReturn<String>():
        expect(data.result.message, contains("Cod. 02-1"));
        expect(data.result.message, contains("simulated network failure"));
    }
  });

  test('funcionamento em Isolate com runInIsolate: true', () async {
    final usecase = CheckConnectionUsecase(
      datasource: const FakeConnectivityDatasource(online: true),
      runInIsolate: true,
    );
    final data = await usecase(params);

    switch (data) {
      case SuccessReturn<String>():
        expect(data.result, equals("You are connected"));
      case ErrorReturn<String>():
        fail('Esperava SuccessReturn');
    }
  });
}
