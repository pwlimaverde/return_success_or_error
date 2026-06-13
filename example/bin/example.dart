import 'package:return_success_or_error/return_success_or_error.dart';
import 'package:return_success_or_error_example/features/check_connection/datasources/fake_connectivity_datasource.dart';
import 'package:return_success_or_error_example/features/check_connection/domain/usecase/check_connection_usecase.dart';
import 'package:return_success_or_error_example/features/fibonacci/domain/parameters/fibonacci_parameters.dart';
import 'package:return_success_or_error_example/features/fibonacci/domain/usecase/fibonacci_usecase.dart';

Future<void> main() async {
  print("== return_success_or_error — pure Dart example ==\n");

  await _checkConnection();
  await _fibonacci();
}

/// Demonstrates a usecase that consumes a datasource, in its three flows:
/// success, business error (offline) and a thrown exception captured by
/// `resultDatasource`.
Future<void> _checkConnection() async {
  print("--- CheckConnection (UsecaseBaseCallData) ---");

  // 1) Success — switch handling.
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

  // 2) Business error (offline) — fold handling.
  final offline = CheckConnectionUsecase(
    datasource: const FakeConnectivityDatasource(online: false),
  );
  final r2 = await offline(
    NoParams(error: const ErrorGeneric(message: "connection error")),
  );
  print(
    r2.fold(
      onSuccess: (value) => "ok  -> $value",
      onError: (error) => "err -> ${error.message}",
    ),
  );

  // 3) Datasource throws — captured and enriched by resultDatasource.
  final failing = CheckConnectionUsecase(
    datasource: const FakeConnectivityDatasource(shouldThrow: true),
  );
  final r3 = await failing(
    NoParams(error: const ErrorGeneric(message: "connection error")),
  );
  print(
    r3.fold(
      onSuccess: (value) => "ok  -> $value",
      onError: (error) => "err -> ${error.message}",
    ),
  );

  print("");
}

/// Demonstrates a pure business-rule usecase running on a background isolate.
Future<void> _fibonacci() async {
  print("--- Fibonacci (UsecaseBase.callIsolate) ---");

  final usecase = FibonacciUsecase();
  final result = await usecase.callIsolate(
    const FibonacciParameters(
      n: 30,
      error: ErrorGeneric(message: "fibonacci error"),
    ),
  );

  print(
    result.fold(
      onSuccess: (value) => "ok  -> fib(30) = $value",
      onError: (error) => "err -> ${error.message}",
    ),
  );
}
