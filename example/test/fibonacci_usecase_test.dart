import 'package:return_success_or_error/return_success_or_error.dart';
import 'package:return_success_or_error_example/features/fibonacci/domain/parameters/fibonacci_parameters.dart';
import 'package:return_success_or_error_example/features/fibonacci/domain/usecase/fibonacci_usecase.dart';
import 'package:test/test.dart';

void main() {
  final usecase = FibonacciUsecase();

  FibonacciParameters params(int n) => FibonacciParameters(
    n: n,
    error: const ErrorGeneric(message: "fibonacci error"),
  );

  test('fib(0) = 0 e fib(1) = 1', () async {
    final r0 = await usecase(params(0));
    final r1 = await usecase(params(1));

    switch (r0) {
      case SuccessReturn<int>():
        expect(r0.result, equals(0));
      case ErrorReturn<int>():
        fail('Esperava SuccessReturn para fib(0)');
    }

    switch (r1) {
      case SuccessReturn<int>():
        expect(r1.result, equals(1));
      case ErrorReturn<int>():
        fail('Esperava SuccessReturn para fib(1)');
    }
  });

  test('fib(10) = 55', () async {
    final data = await usecase(params(10));
    switch (data) {
      case SuccessReturn<int>():
        expect(data.result, equals(55));
      case ErrorReturn<int>():
        fail('Esperava SuccessReturn');
    }
  });

  test('fib(30) = 832040', () async {
    final data = await usecase(params(30));
    switch (data) {
      case SuccessReturn<int>():
        expect(data.result, equals(832040));
      case ErrorReturn<int>():
        fail('Esperava SuccessReturn');
    }
  });

  test('n negativo retorna ErrorReturn', () async {
    final data = await usecase(params(-1));
    switch (data) {
      case SuccessReturn<int>():
        fail('Esperava ErrorReturn');
      case ErrorReturn<int>():
        expect(data.result.message, equals("n must be >= 0"));
    }
  });

  test('executando com runInIsolate: true produz o mesmo resultado', () async {
    const isolateUsecase = FibonacciUsecase(runInIsolate: true);
    final data = await isolateUsecase(params(20));
    switch (data) {
      case SuccessReturn<int>():
        expect(data.result, equals(6765));
      case ErrorReturn<int>():
        fail('Esperava SuccessReturn');
    }
  });
}
