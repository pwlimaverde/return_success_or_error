import 'package:return_success_or_error/src/core/runtime_milliseconds.dart';
import 'package:test/test.dart';

void main() {
  final runtime = RuntimeMilliseconds();

  test('Deve medir o tempo decorrido em milissegundos', () async {
    runtime.startScore();
    await Future<void>.delayed(const Duration(seconds: 2));
    runtime.finishScore();

    expect(runtime.calculateRuntime(), greaterThanOrEqualTo(2000));
  });
}
