import 'package:return_success_or_error/return_success_or_error.dart';
import 'package:return_success_or_error_example/features/fibonacci/domain/errors/fibonacci_errors.dart';
import 'package:return_success_or_error_example/features/fibonacci/domain/parameters/fibonacci_parameters.dart';
import 'package:return_success_or_error_example/features/fibonacci/domain/usecase/fibonacci_usecase.dart';
import 'package:test/test.dart';

void main() {
  group('FibonacciUsecase', () {
    test('Deve retornar um success com fib(10)', () async {
      final result = await const FibonacciUsecase()(
        const FibonacciParameters(n: 10),
      );

      expect(result, equals(const Success<int, FibonacciError>(55)));
    });

    test('Deve retornar um success com fib(30) em isolate', () async {
      final result = await const FibonacciUsecase(runInIsolate: true)(
        const FibonacciParameters(n: 30),
      );

      expect(result, equals(const Success<int, FibonacciError>(832040)));
    });

    test('Deve retornar NegativeIndex para n < 0', () async {
      final result = await const FibonacciUsecase()(
        const FibonacciParameters(n: -1),
      );

      switch (result) {
        case Success():
          fail('Esperava Failure');
        case Failure(:final error):
          expect(error, isA<NegativeIndex>());
          expect(error.message, equals('n must be >= 0'));
      }
    });

    test('Resultado idêntico no caminho direto e no isolate', () async {
      const parameters = FibonacciParameters(n: 25);

      expect(
        await const FibonacciUsecase(runInIsolate: true)(parameters),
        equals(await const FibonacciUsecase()(parameters)),
      );
    });
  });
}
