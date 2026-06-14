import 'dart:developer';
import 'dart:isolate';

import 'package:meta/meta.dart';

import '../../return_success_or_error.dart';

/// Código anexado por [UsecaseBaseCallData] quando o datasource lança uma
/// exceção, marcando onde no fluxo a falha foi capturada.
const String _datasourceCatchCode = "Cod. 02-1";

/// Código anexado quando a execução em [Isolate.run] lança uma exceção,
/// marcando onde no fluxo a falha foi capturada.
const String _isolateCatchCode = "Cod. IsolateCatch";

/// Assinatura da regra de negócio de [UsecaseBaseCallData].
///
/// Recebe o dado **bruto já carregado** pelo datasource (o valor de sucesso, já
/// desempacotado) e os [parameters], e devolve o resultado final do usecase.
///
/// **Deve ser uma função estática ou top-level** (tear-off sem `this`): é ela
/// que roda dentro do [Isolate.run] quando `runInIsolate` é `true`, e capturar
/// `this` arrastaria o datasource (e seus recursos nativos) para o isolate. Por
/// isso recebe tudo de que precisa via parâmetros — não acessa campos da
/// instância. Se precisar de campos específicos do parâmetro, faça o cast do
/// [parameters] para o seu tipo concreto dentro da função.
typedef ProcessData<TypeUsecase, TypeDatasource> =
    ReturnSuccessOrError<TypeUsecase> Function(
      TypeDatasource data,
      ParametersReturnResult parameters,
    );

/// Assinatura da regra de negócio pura de [UsecaseBase] (sem datasource).
///
/// Recebe apenas os [parameters] e devolve o resultado final. Valem as mesmas
/// regras de [ProcessData]: deve ser estática/top-level para rodar com segurança
/// em [Isolate.run].
typedef ProcessPure<TypeUsecase> =
    ReturnSuccessOrError<TypeUsecase> Function(
      ParametersReturnResult parameters,
    );

/// Constrói um [ErrorReturn] enriquecendo a mensagem do [AppError] original com
/// o [code] do ponto de captura e o erro bruto [e].
///
/// O `copyWith` é polimórfico, então o **tipo concreto** do [AppError] é
/// preservado (um `ApiError` continua `ApiError`).
ErrorReturn<T> _errorWithCatch<T>(
  ParametersReturnResult parameters,
  String code,
  Object e,
) => ErrorReturn(
  error: parameters.error.copyWith(
    message: "${parameters.error.message} - $code --- Catch: $e",
  ),
);

void _logTime(Object runner, int milliseconds, {required bool isIsolate}) {
  final message =
      "Execution Time ${runner.runtimeType} ${isIsolate ? '(Isolate)' : '(Direct)'}: ${milliseconds}ms";

  // Intencional: monitorExecutionTime é opt-in para depuração e o print é a
  // única saída visível em `dart run` / `dart test`.
  // ignore: avoid_print
  print("[return_success_or_error] $message");

  // Também loga via dart:developer para quem estiver no DevTools/Observatory.
  log(message, name: "return_success_or_error");
}

/// Executa [stage] diretamente ou em um [Isolate] de background conforme
/// [runInIsolate], convertendo falhas do isolate em [ErrorReturn].
///
/// [stage] **não pode capturar `this`** — passe sempre um tear-off estático
/// fechado apenas sobre dados serializáveis.
Future<ReturnSuccessOrError<T>> _runStage<T>(
  ParametersReturnResult parameters, {
  required bool runInIsolate,
  required ReturnSuccessOrError<T> Function() stage,
}) async {
  if (!runInIsolate) return stage();

  try {
    return await Isolate.run(stage);
  } catch (e) {
    return _errorWithCatch<T>(parameters, _isolateCatchCode, e);
  }
}

/// Regra de negócio pura, sem nenhuma chamada externa (datasource).
///
/// A subclasse implementa apenas o getter [process], apontando para uma função
/// **estática** que recebe os [ParametersReturnResult] e devolve o resultado.
/// Quando construído com `runInIsolate: true`, o [process] roda em um isolate de
/// background.
///
/// ```dart
/// final class FibonacciUsecase extends UsecaseBase<int> {
///   const FibonacciUsecase({super.runInIsolate});
///
///   @override
///   ProcessPure<int> get process => _process;
///
///   static ReturnSuccessOrError<int> _process(ParametersReturnResult p) {
///     final params = p as FibonacciParameters;
///     return SuccessReturn(success: _fib(params.n));
///   }
/// }
/// ```
abstract base class UsecaseBase<TypeUsecase> {
  /// Indica se o [process] deve rodar em um [Isolate] de background.
  final bool runInIsolate;

  /// Indica se o tempo de execução deve ser medido e logado.
  ///
  /// Desligado por padrão: medir e logar só faz sentido durante o
  /// desenvolvimento (ex.: comparar `runInIsolate: false` vs `true`). Mantê-lo
  /// `false` em produção evita o custo do [Stopwatch] e do `log`.
  final bool monitorExecutionTime;

  const UsecaseBase({
    this.runInIsolate = false,
    this.monitorExecutionTime = false,
  });

  /// A regra de negócio: uma função **estática** que recebe os parâmetros e
  /// devolve o resultado. Veja [ProcessPure].
  @protected
  ProcessPure<TypeUsecase> get process;

  /// Executa o usecase.
  ///
  /// Roda o [process] (direto ou em isolate, conforme [runInIsolate]) e,
  /// quando [monitorExecutionTime] é `true`, mede e loga o tempo total.
  Future<ReturnSuccessOrError<TypeUsecase>> call(
    covariant ParametersReturnResult parameters,
  ) async {
    final fn = process; // avalia o tear-off no isolate principal

    if (!monitorExecutionTime) {
      return _runStage<TypeUsecase>(
        parameters,
        runInIsolate: runInIsolate,
        stage: () => fn(parameters),
      );
    }

    final stopwatch = Stopwatch()..start();
    final result = await _runStage<TypeUsecase>(
      parameters,
      runInIsolate: runInIsolate,
      stage: () => fn(parameters),
    );
    stopwatch.stop();
    _logTime(this, stopwatch.elapsedMilliseconds, isIsolate: runInIsolate);
    return result;
  }
}

/// Regra de negócio que consome um [Datasource].
///
/// [TypeUsecase] é o tipo retornado pelo usecase; [TypeDatasource] é o tipo cru
/// devolvido pelo datasource.
///
/// O fluxo é totalmente orquestrado pela base:
/// 1. **Fetch** — chama o datasource (privado) no isolate principal. A chamada é
///    assíncrona e **nunca cruza a fronteira do isolate**, então datasources com
///    recursos nativos (conexão de banco, socket) funcionam normalmente.
/// 2. **Short-circuit** — se o datasource falhar, o erro é devolvido
///    automaticamente; o [process] nem é chamado.
/// 3. **Process** — com o dado bruto já carregado, executa o [process] (direto
///    ou em isolate, conforme [runInIsolate]).
///
/// A subclasse implementa apenas o getter [process] (função estática). O
/// datasource é mantido **privado**: as subclasses nunca o acessam.
///
/// ```dart
/// final class CheckConnectionUsecase
///     extends UsecaseBaseCallData<String, bool> {
///   CheckConnectionUsecase({required super.datasource, super.runInIsolate});
///
///   @override
///   ProcessData<String, bool> get process => _process;
///
///   static ReturnSuccessOrError<String> _process(
///     bool online,
///     ParametersReturnResult p,
///   ) => online
///       ? const SuccessReturn(success: "online")
///       : ErrorReturn(error: p.error.copyWith(message: "offline"));
/// }
/// ```
abstract base class UsecaseBaseCallData<TypeUsecase, TypeDatasource> {
  final Datasource<TypeDatasource> _datasource;

  /// Indica se o [process] deve rodar em um [Isolate] de background.
  ///
  /// Afeta **somente** o processamento (fase 3) — o fetch do datasource (fase 1)
  /// roda sempre no isolate principal.
  final bool runInIsolate;

  /// Indica se o tempo de execução total deve ser medido e logado.
  ///
  /// Mede fetch + process. Como o fetch é idêntico nas duas formas, a diferença
  /// entre `runInIsolate: false` e `true` reflete a decisão de processamento —
  /// útil para comparar durante o desenvolvimento. Veja
  /// [UsecaseBase.monitorExecutionTime].
  final bool monitorExecutionTime;

  /// O datasource é recebido como private named parameter (Dart 3.12): o
  /// chamador usa o nome público `datasource`, mas o campo permanece privado.
  UsecaseBaseCallData({
    required this._datasource,
    this.runInIsolate = false,
    this.monitorExecutionTime = false,
  });

  /// A regra de negócio: uma função **estática** que recebe o dado bruto já
  /// carregado pelo datasource e os parâmetros, e devolve o resultado. Veja
  /// [ProcessData].
  @protected
  ProcessData<TypeUsecase, TypeDatasource> get process;

  /// Executa o usecase: fetch → short-circuit no erro → process.
  ///
  /// Quando [monitorExecutionTime] é `true`, mede e loga o tempo total.
  Future<ReturnSuccessOrError<TypeUsecase>> call(
    covariant ParametersReturnResult parameters,
  ) async {
    if (!monitorExecutionTime) return _run(parameters);

    final stopwatch = Stopwatch()..start();
    final result = await _run(parameters);
    stopwatch.stop();
    _logTime(this, stopwatch.elapsedMilliseconds, isIsolate: runInIsolate);
    return result;
  }

  Future<ReturnSuccessOrError<TypeUsecase>> _run(
    ParametersReturnResult parameters,
  ) async {
    // Fase 1 — fetch no isolate principal (datasource nunca cruza a fronteira).
    final resultDatasource = await _resultDatasource(parameters);

    switch (resultDatasource) {
      // Fase 2 — short-circuit automático no erro.
      case ErrorReturn(:final result):
        return ErrorReturn<TypeUsecase>(error: result);
      // Fase 3 — processa o dado bruto já carregado (direto ou em isolate).
      case SuccessReturn(:final result):
        final fn = process; // avalia o tear-off no isolate principal
        return _runStage<TypeUsecase>(
          parameters,
          runInIsolate: runInIsolate,
          stage: () => fn(result, parameters),
        );
    }
  }

  /// Invoca o datasource privado dentro de um `try/catch`, encapsulando o
  /// resultado em um [ReturnSuccessOrError]. Em caso de falha, a mensagem do
  /// [AppError] original é preservada e enriquecida (via `copyWith`) com o
  /// contexto do catch (`Cod. 02-1`).
  Future<ReturnSuccessOrError<TypeDatasource>> _resultDatasource(
    ParametersReturnResult parameters,
  ) async {
    try {
      final result = await _datasource(parameters);
      return SuccessReturn(success: result);
    } catch (e) {
      return _errorWithCatch<TypeDatasource>(
        parameters,
        _datasourceCatchCode,
        e,
      );
    }
  }
}
