import 'dart:developer' as developer;
import 'dart:isolate';

import 'package:meta/meta.dart';

import '../core/return_success_or_error.dart';

/// Base compartilhada pelos casos de uso. Concentra o que é comum aos dois
/// fluxos (`UsecaseBase` e `UsecaseBaseCallData`): a medição opcional do tempo e
/// o despacho opcional do processamento (CPU-bound) para um [Isolate].
///
/// As subclasses definem o fluxo específico e o `process`.
abstract base class UsecaseExecutorBase<TValue, TError> {
  /// Se `true`, o **processamento** roda em um [Isolate] de background.
  ///
  /// Afeta **somente** o processamento. A busca de dados (I/O) nunca vai para o
  /// isolate: despachar I/O assíncrono para outra thread é desperdício, e é o
  /// que permite que datasources com recursos nativos (conexão de banco, socket)
  /// funcionem mesmo com esta opção ligada.
  final bool runInIsolate;

  /// Se `true`, mede o tempo de execução e o entrega a
  /// [onExecutionTimeMeasured].
  ///
  /// Desligado por padrão: medir só faz sentido durante o desenvolvimento (ex.:
  /// comparar `runInIsolate: false` vs `true`).
  final bool monitorExecutionTime;

  const UsecaseExecutorBase({
    this.runInIsolate = false,
    this.monitorExecutionTime = false,
  });

  /// Converte uma exceção **inesperada** do `process` (ou seja: um bug, não uma
  /// falha prevista) em um erro do conjunto fechado da feature.
  ///
  /// **Abstrato de propósito:** como não há erro universal que a base possa
  /// fabricar, é o caso de uso que decide para qual caso de [TError] o
  /// inesperado é mapeado — tipicamente um caso "unexpected" (`ErrorGeneric`
  /// serve). Isso garante que o `process` **nunca lança para o chamador**: o
  /// resultado é sempre um dos casos previstos.
  ///
  /// > **Mudança em relação à v2:** antes, uma exceção no processamento virava
  /// > uma cópia do erro dos parâmetros com o sufixo `"Cod. IsolateCatch"`
  /// > concatenado na mensagem — e só era capturada no caminho do isolate. Agora
  /// > a captura vale para os **dois** caminhos e o erro produzido é escolhido
  /// > pela feature.
  ///
  /// O [stackTrace] acompanha a exceção porque, em Dart, ele não viaja dentro
  /// dela — descartá-lo aqui apagaria a origem do bug. Ignorá-lo é normal;
  /// ele existe para quem precisa reportá-lo.
  @protected
  TError onUnexpected(Object exception, StackTrace stackTrace);

  /// Recebe o tempo medido quando [monitorExecutionTime] está ligado.
  ///
  /// Sobrescreva para plugar a sua observabilidade (um logger, uma métrica) — a
  /// biblioteca não impõe dependência de logging. A implementação padrão escreve
  /// via `dart:developer`, visível no DevTools:
  ///
  /// ```dart
  /// @override
  /// void onExecutionTimeMeasured(Duration elapsed) =>
  ///     print('$runtimeType levou ${elapsed.inMilliseconds}ms');
  /// ```
  @protected
  void onExecutionTimeMeasured(Duration elapsed) => developer.log(
    'Execution Time $runtimeType '
    '(${runInIsolate ? 'Isolate' : 'Direct'}): ${elapsed.inMilliseconds}ms',
    name: 'return_success_or_error',
  );

  /// Envolve a execução com a medição de tempo, quando habilitada.
  @protected
  Future<ReturnSuccessOrError<TValue, TError>> measured(
    Future<ReturnSuccessOrError<TValue, TError>> Function() run,
  ) async {
    if (!monitorExecutionTime) return run();

    final stopwatch = Stopwatch()..start();
    final result = await run();
    stopwatch.stop();
    onExecutionTimeMeasured(stopwatch.elapsed);
    return result;
  }

  /// Executa o [process] direto ou, se [runInIsolate], em um [Isolate].
  ///
  /// Em **ambos** os modos, uma exceção inesperada é convertida via
  /// [onUnexpected] em `Failure` — o `process` nunca propaga exceção ao
  /// chamador.
  ///
  /// O [process] **não pode capturar `this`**: passe sempre um tear-off de
  /// função estática fechado apenas sobre dados sendáveis, senão o
  /// [Isolate.run] falha ao serializar a closure — e essa própria falha de
  /// serialização também chega aqui como exceção, virando [onUnexpected].
  ///
  /// O isolate recebe um `debugName` com o tipo do caso de uso, para que o
  /// worker apareça identificado no DevTools em vez de anônimo.
  @protected
  Future<ReturnSuccessOrError<TValue, TError>> processStage(
    ReturnSuccessOrError<TValue, TError> Function() process,
  ) async {
    try {
      return runInIsolate
          ? await Isolate.run(process, debugName: '$runtimeType.process')
          : process();
    } catch (exception, stackTrace) {
      return Failure(onUnexpected(exception, stackTrace));
    }
  }
}
