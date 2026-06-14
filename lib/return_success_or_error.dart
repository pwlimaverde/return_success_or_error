library;

/// Classes base para a regra de negócio de uma feature.
///
/// [UsecaseBase] executa uma regra de negócio pura (sem chamada externa);
/// [UsecaseBaseCallData] consome um [Datasource] e faz a ponte com ele através
/// do método `resultDatasource` (a única ponte entre usecase e datasource).
export 'src/bases/usecase_base.dart';

/// O tipo de resultado selado e seus dois casos.
///
/// [ReturnSuccessOrError] guarda ou um [SuccessReturn] (o valor de sucesso) ou
/// um [ErrorReturn] (um [AppError]). Por ser selado, força o tratamento
/// exaustivo via `switch`. Também expõe os singletons `Unit`/`Nil`, que
/// representam, respectivamente, `void` e `null` como resultado de sucesso.
export 'src/core/return_success_or_error.dart';

/// A abstração da chamada externa.
///
/// Um [Datasource] executa a chamada externa e deve retornar o tipo de dado
/// predefinido, ou então `throw` no [AppError] carregado pelos parâmetros (um
/// [Exception]) em caso de falha.
export 'src/interfaces/datasource.dart';

/// O contrato de erro imutável e sua implementação padrão.
///
/// Implementações de [AppError] expõem o getter `message` e produzem cópias
/// enriquecidas via `copyWith` (os erros são imutáveis: nunca se muta, sempre se
/// copia). [ErrorGeneric] é a implementação concreta pronta para uso.
export 'src/interfaces/errors.dart';

/// A abstração dos parâmetros da chamada.
///
/// Implementações de [ParametersReturnResult] carregam os dados exigidos pelo
/// datasource e são obrigadas a expor o [AppError] retornado em caso de falha.
/// [NoParams] é a implementação pronta para chamadas sem dados extras.
export 'src/interfaces/parameters.dart';
