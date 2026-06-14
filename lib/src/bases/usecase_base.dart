import 'dart:developer';
import 'dart:isolate';

import 'package:meta/meta.dart';

import '../../return_success_or_error.dart';

/// Código anexado por [UsecaseBaseCallData.resultDatasource] quando o datasource
/// lança uma exceção, marcando onde no fluxo a falha foi capturada.
const String _datasourceCatchCode = "Cod. 02-1";

/// Código anexado por [_UsecaseRunner.call] quando a execução em [Isolate.run]
/// lança uma exceção, marcando onde no fluxo a falha foi capturada.
const String _isolateCatchCode = "Cod. IsolateCatch";

/// Constrói um [ErrorReturn] enriquecendo a mensagem do [AppError] original com
/// o [code] do ponto de captura e o erro bruto [e].
///
/// O `copyWith` é polimórfico, então o **tipo concreto** do [AppError] é
/// preservado (um `ApiError` continua `ApiError`). É a única forma de produzir
/// o erro de catch no pacote, garantindo que o formato da mensagem nunca divirja
/// entre os pontos de captura.
ErrorReturn<T> _errorWithCatch<T>(
  ParametersReturnResult parameters,
  String code,
  Object e,
) => ErrorReturn(
  error: parameters.error.copyWith(
    message: "${parameters.error.message} - $code --- Catch: $e",
  ),
);

/// Contrato `call` compartilhado pelas duas classes base de usecase.
///
/// Define o [run] abstrato (onde as subclasses implementam a regra de negócio)
/// e um [call] concreto que gerencia a execução (direta ou via [Isolate.run]),
/// medindo o tempo decorrido **apenas** quando [monitorExecutionTime] é `true`.
base mixin _UsecaseRunner<TypeUsecase> {
  /// Indica se a execução deve rodar em um [Isolate] de background.
  bool get runInIsolate;

  /// Indica se o tempo de execução deve ser medido e logado.
  ///
  /// Desligado por padrão: medir e logar só faz sentido durante o
  /// desenvolvimento. Mantê-lo `false` em produção evita o custo do
  /// [Stopwatch] e do `log`. Ligue (ex.: `super.monitorExecutionTime: true`)
  /// apenas quando estiver perfilando o usecase.
  bool get monitorExecutionTime;

  /// A regra de negócio central que as subclasses devem implementar.
  @protected
  Future<ReturnSuccessOrError<TypeUsecase>> run(
    covariant ParametersReturnResult parameters,
  );

  /// Executa o usecase.
  ///
  /// Se [monitorExecutionTime] for `true`, mede o tempo total com um
  /// [Stopwatch] e o loga via [_logTime]; caso contrário, executa sem nenhum
  /// custo de medição. A escolha entre isolate e execução direta é delegada a
  /// [_execute].
  Future<ReturnSuccessOrError<TypeUsecase>> call(
    covariant ParametersReturnResult parameters,
  ) async {
    if (!monitorExecutionTime) {
      return _execute(parameters);
    }

    final stopwatch = Stopwatch()..start();
    final result = await _execute(parameters);
    stopwatch.stop();
    _logTime(stopwatch.elapsedMilliseconds, isIsolate: runInIsolate);
    return result;
  }

  /// Executa [run] diretamente ou em um [Isolate] de background, conforme
  /// [runInIsolate], convertendo falhas do isolate em [ErrorReturn].
  Future<ReturnSuccessOrError<TypeUsecase>> _execute(
    ParametersReturnResult parameters,
  ) async {
    Future<ReturnSuccessOrError<TypeUsecase>> run0() => run(parameters);

    if (!runInIsolate) {
      return run0();
    }

    try {
      return await Isolate.run(run0);
    } catch (e) {
      return _errorWithCatch<TypeUsecase>(parameters, _isolateCatchCode, e);
    }
  }

  void _logTime(int milliseconds, {required bool isIsolate}) {
    log(
      "Execution Time $runtimeType${isIsolate ? ' (Isolate)' : ''}: ${milliseconds}ms",
      name: "return_success_or_error",
    );
  }
}

/// Regra de negócio pura, sem nenhuma chamada externa (datasource).
abstract base class UsecaseBase<TypeUsecase> with _UsecaseRunner<TypeUsecase> {
  @override
  final bool runInIsolate;

  @override
  final bool monitorExecutionTime;

  const UsecaseBase({
    this.runInIsolate = false,
    this.monitorExecutionTime = false,
  });
}

/// Regra de negócio que consome um [Datasource].
///
/// [TypeUsecase] é o tipo retornado pelo usecase; [TypeDatasource] é o tipo cru
/// devolvido pelo datasource. O datasource é fornecido pelo construtor e mantido
/// **privado**: as subclasses nunca o acessam diretamente — invocam
/// [resultDatasource], a única ponte entre usecase e datasource.
///
/// As subclasses encaminham o datasource via super parameter:
/// ```dart
/// final class MyUsecase extends UsecaseBaseCallData<Foo, Bar> {
///   MyUsecase({required super.datasource, super.runInIsolate});
///
///   @override
///   Future<ReturnSuccessOrError<Foo>> run(MyParams parameters) async {
///     final result = await resultDatasource(parameters);
///     return switch (result) { ... };
///   }
/// }
/// ```
abstract base class UsecaseBaseCallData<TypeUsecase, TypeDatasource>
    with _UsecaseRunner<TypeUsecase> {
  final Datasource<TypeDatasource> _datasource;

  @override
  final bool runInIsolate;

  @override
  final bool monitorExecutionTime;

  /// O datasource é recebido como private named parameter (Dart 3.12): o
  /// chamador usa o nome público `datasource`, mas o campo permanece privado.
  UsecaseBaseCallData({
    required this._datasource,
    this.runInIsolate = false,
    this.monitorExecutionTime = false,
  });

  /// Invoca o datasource dentro de um `try/catch`, encapsulando o resultado em
  /// um [ReturnSuccessOrError]. Em caso de falha, a mensagem do [AppError]
  /// original é preservada e enriquecida (via `copyWith`) com o contexto do
  /// catch.
  ///
  /// Destinado a ser chamado apenas por subclasses — é a única ponte entre
  /// usecase e datasource.
  @protected
  Future<ReturnSuccessOrError<TypeDatasource>> resultDatasource(
    covariant ParametersReturnResult parameters,
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
