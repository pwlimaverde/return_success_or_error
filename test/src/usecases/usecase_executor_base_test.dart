import 'package:return_success_or_error/return_success_or_error.dart';
import 'package:test/test.dart';

import '../../test_fixtures.dart';

/// Usecase que substitui o hook de observabilidade por uma captura em memória —
/// é exatamente o ponto de extensão que um consumidor usaria para plugar um
/// logger ou uma métrica.
final class MedidoUsecase extends UsecaseBase<String, TestParams, TestError> {
  final List<Duration> medicoes = [];

  MedidoUsecase({super.runInIsolate, super.monitorExecutionTime});

  @override
  ProcessPure<String, TestParams, TestError> get process => _process;

  @override
  TestError onUnexpected(Object exception, StackTrace stackTrace) =>
      UnexpectedError('$exception');

  @override
  void onExecutionTimeMeasured(Duration elapsed) => medicoes.add(elapsed);

  static ReturnSuccessOrError<String, TestError> _process(TestParams p) =>
      Success(p.nome);
}

/// Usecase cujo `process` lança e que registra o stack trace recebido.
final class ExplodeMedidoUsecase
    extends UsecaseBase<String, TestParams, TestError> {
  ExplodeMedidoUsecase({required this.capturado});

  final List<StackTrace> capturado;

  @override
  ProcessPure<String, TestParams, TestError> get process => _process;

  @override
  TestError onUnexpected(Object exception, StackTrace stackTrace) {
    capturado.add(stackTrace);
    return UnexpectedError('$exception');
  }

  static ReturnSuccessOrError<String, TestError> _process(TestParams p) =>
      throw StateError('boom');
}

void main() {
  const parameters = TestParams(nome: 'medicao');

  group('onExecutionTimeMeasured', () {
    test('NÃO é chamado quando monitorExecutionTime está desligado', () async {
      final usecase = MedidoUsecase();

      await usecase(parameters);

      expect(usecase.medicoes, isEmpty);
    });

    test('É chamado uma vez por execução quando ligado', () async {
      final usecase = MedidoUsecase(monitorExecutionTime: true);

      await usecase(parameters);
      await usecase(parameters);

      expect(usecase.medicoes, hasLength(2));
      expect(usecase.medicoes.every((d) => d >= Duration.zero), isTrue);
    });

    test('É chamado também no caminho isolate', () async {
      final usecase = MedidoUsecase(
        runInIsolate: true,
        monitorExecutionTime: true,
      );

      await usecase(parameters);

      expect(usecase.medicoes, hasLength(1));
    });
  });

  group('onUnexpected', () {
    test('Deve receber o stack trace da exceção do process', () async {
      final capturado = <StackTrace>[];
      final usecase = ExplodeMedidoUsecase(capturado: capturado);

      await usecase(parameters);

      expect(capturado, hasLength(1));
      expect(capturado.single, isNot(StackTrace.empty));
    });
  });

  group('Flags de execução', () {
    test('Padrões: execução direta e sem medição', () {
      final usecase = MedidoUsecase();

      expect(usecase.runInIsolate, isFalse);
      expect(usecase.monitorExecutionTime, isFalse);
    });
  });
}
