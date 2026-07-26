/// Abstração de Clean Architecture para casos de uso, com o resultado de toda
/// chamada encapsulado em um `ReturnSuccessOrError<TValue, TError>` — sucesso ou
/// erro, nunca uma exceção vazando entre as camadas.
///
/// O fluxo de uma feature atravessa três camadas:
///
/// **`Datasource` → `Repository` → `Usecase`**
///
/// - [Datasource] é burro: devolve o dado bruto **ou lança** a exceção técnica.
/// - [RepositoryBase] é a fronteira: captura e traduz a exceção em um erro do
///   conjunto fechado da feature via `mapError`.
/// - [UsecaseBase] / [UsecaseBaseCallData] executam a regra de negócio e
///   devolvem [Success] ou [Failure].
library;

/// `Nil` — o `null` como resultado válido e esperado.
export 'src/core/nil.dart';

/// O tipo de resultado selado e seus dois casos, [Success] e [Failure].
///
/// Com o **erro parametrizado**, cada feature fecha o seu conjunto de erros em
/// uma hierarquia `sealed`, e o `switch` fica exaustivo nos dois níveis.
export 'src/core/return_success_or_error.dart';

/// `Unit` — o `void` como resultado.
export 'src/core/unit.dart';

/// A abstração da chamada externa (camada de infraestrutura).
export 'src/datasources/datasource.dart';

/// [AppError] — base opcional para os erros de domínio da sua feature.
export 'src/errors/app_error.dart';

/// [ErrorGeneric] — caso concreto pronto para o "inesperado".
export 'src/errors/error_generic.dart';

/// [NoParams] / `noParams` — parâmetros vazios.
export 'src/parameters/no_params.dart';

/// [Parameters] — os dados da chamada (e **somente** dados).
export 'src/parameters/parameters.dart';

/// O contrato da camada de dados, do qual o caso de uso depende (DIP).
export 'src/repositories/repository.dart';

/// A fronteira que traduz exceção técnica em erro de domínio (`mapError`).
export 'src/repositories/repository_base.dart';

/// Caso de uso de lógica pura, sem fonte de dados.
export 'src/usecases/usecase_base.dart';

/// Caso de uso com fonte de dados: fetch → curto-circuito → process.
export 'src/usecases/usecase_base_call_data.dart';

/// A base compartilhada: `runInIsolate`, `monitorExecutionTime`,
/// `onUnexpected` e o hook `onExecutionTimeMeasured`.
export 'src/usecases/usecase_executor_base.dart';
