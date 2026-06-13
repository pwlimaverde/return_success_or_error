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
    expect((await usecase(params(0))).getOrNull, equals(0));
    expect((await usecase(params(1))).getOrNull, equals(1));
  });

  test('fib(10) = 55', () async {
    final data = await usecase(params(10));
    expect(data.isSuccess, isTrue);
    expect(data.getOrNull, equals(55));
  });

  test('fib(30) = 832040', () async {
    expect((await usecase(params(30))).getOrNull, equals(832040));
  });

  test('n negativo retorna ErrorReturn', () async {
    final data = await usecase(params(-1));
    expect(data.isError, isTrue);
    expect((data as ErrorReturn<int>).result.message, equals("n must be >= 0"));
  });

  test('callIsolate produz o mesmo resultado', () async {
    final data = await usecase.callIsolate(params(20));
    expect(data.getOrNull, equals(6765));
  });
}
