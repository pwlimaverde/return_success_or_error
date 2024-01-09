import 'package:flutter_test/flutter_test.dart';
import 'package:return_success_or_error/src/core/runtime_milliseconds.dart';

void main() {
  final RuntimeMilliseconds runtime = RuntimeMilliseconds();
  test('Deve retornar o resultado dos Parâmetros', () async {
    runtime.startScore();
    await Future.delayed(Duration(seconds: 2));
    runtime.finishScore();

    final teste = runtime.calculateRuntime() > 2000 ? true : false;

    print("Execution Time: ${runtime.calculateRuntime()}ms");

    expect(teste, equals(true));
  });
}
