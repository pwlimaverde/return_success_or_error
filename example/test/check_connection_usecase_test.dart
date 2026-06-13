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

    expect(data.isSuccess, isTrue);
    expect(data.getOrNull, equals("You are connected"));
  });

  test('offline -> error de negócio "You are offline"', () async {
    final usecase = CheckConnectionUsecase(
      datasource: const FakeConnectivityDatasource(online: false),
    );
    final data = await usecase(params);

    expect(data.isError, isTrue);
    expect(
      (data as ErrorReturn<String>).result.message,
      equals("You are offline"),
    );
  });

  test('exceção do datasource -> error enriquecido com Cod. 02-1', () async {
    final usecase = CheckConnectionUsecase(
      datasource: const FakeConnectivityDatasource(shouldThrow: true),
    );
    final data = await usecase(params);

    expect(data, isA<ErrorReturn<String>>());
    final message = (data as ErrorReturn<String>).result.message;
    expect(message, contains("Cod. 02-1"));
    expect(message, contains("simulated network failure"));
  });
}
