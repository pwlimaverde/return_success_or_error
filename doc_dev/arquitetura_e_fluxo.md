# Arquitetura e fluxo — `return_success_or_error`

> Referência **interna** (estado final pós-refator v2.0.0). Descreve o "porquê" de cada peça
> e como elas se conectam. Para o guia de **uso**, veja [README-pt.md](../README-pt.md).
> Para o registro do refator e sugestões, veja [refator/planejamento_refator.md](refator/planejamento_refator.md).

## Objetivo

Centralizar o retorno de qualquer chamada em um único tipo selado (`ReturnSuccessOrError<T>`),
forçando o tratamento explícito de sucesso/erro, separando regra de negócio (usecase) da
chamada externa (datasource) e permitindo isolar o processamento em uma thread (isolate).

## Mapa dos arquivos (`lib/src/`)

| Arquivo | Papel |
|---------|-------|
| `core/return_success_or_error.dart` | Tipo selado `ReturnSuccessOrError<R>` + `SuccessReturn`/`ErrorReturn`, helpers e singletons `Unit`/`Nil`. |
| `bases/usecase_base.dart` | `UsecaseBase`, `UsecaseBaseCallData` (com flags `runInIsolate`/`monitorExecutionTime`), os typedefs `ProcessData`/`ProcessPure` e os helpers privados `_runStage`/`_resultDatasource`. |
| `interfaces/datasource.dart` | Contrato `Datasource<TypeDatasource>`. |
| `interfaces/parameters.dart` | Interface `ParametersReturnResult` + `NoParams`. |
| `interfaces/errors.dart` | Contrato imutável `AppError` + `ErrorGeneric`. |

Tudo é exportado por [lib/return_success_or_error.dart](../lib/return_success_or_error.dart).

## O fluxo, em detalhe

```
chamador
  │  await usecase(parameters)                    // (1) call posicional
  ▼
UsecaseBaseCallData.call(parameters)              // base orquestra tudo
  │
  │  FASE 1 — _resultDatasource(parameters)       // (2) fetch, no isolate principal
  │    try {
  │      final raw = await _datasource(parameters);// (3) datasource privado
  │      return SuccessReturn(success: raw);       //     sucesso cru (TypeDatasource)
  │    } catch (e) {
  │      return ErrorReturn(                        //     erro enriquecido
  │        error: parameters.error.copyWith(
  │          message: "$msg - Cod. 02-1 --- Catch: $e", // preserva tipo/mensagem original
  │        ),
  │      );
  │    }
  ▼
  │  FASE 2 — switch no resultado do fetch:        // (4) short-circuit automático
  │    ErrorReturn<D>()   => return ErrorReturn(...) // process NÃO é chamado
  │    SuccessReturn<D>() => process(raw, parameters)
  ▼
  │  FASE 3 — _runStage(stage: () => process(raw, parameters))  // (5) direto ou em isolate
  ▼
ReturnSuccessOrError<TypeUsecase>                  // (6) resultado final
  →  switch exaustivo (SuccessReturn / ErrorReturn)
```

1. **`call` é posicional e `covariant`.** A assinatura na base é
   `call(covariant ParametersReturnResult parameters)`, e quem orquestra todo o fluxo é a
   **base** — a subclasse só fornece o `process`.
2. **A base faz o fetch** via `_resultDatasource` (privado). Vive dentro de
   `UsecaseBaseCallData` porque privacidade em Dart é **por biblioteca (arquivo)**: para
   enxergar o campo privado `_datasource`, o método precisa estar no mesmo arquivo.
3. O datasource é um **private named parameter** (Dart 3.12): construtor
   `UsecaseBaseCallData({required this._datasource})`, a subclasse encaminha com
   `{required super.datasource}`. O campo `_datasource` nunca é exposto. O fetch envolve a
   chamada em `try/catch`: sucesso → `SuccessReturn<TypeDatasource>` com o valor cru; falha →
   `ErrorReturn` enriquecido via `parameters.error.copyWith(...)` (o `copyWith` é polimórfico,
   então o **tipo concreto** do `AppError` é preservado). O código `Cod. 02-1` vem da
   constante `_datasourceCatchCode`.
4. **Short-circuit automático:** se o fetch falhou, a base devolve o `ErrorReturn` direto — o
   `process` nem é executado.
5. **`process` é uma função estática** (`ProcessData<TypeUsecase, TypeDatasource>`): recebe o
   dado bruto já carregado e os parâmetros, e devolve `ReturnSuccessOrError<TypeUsecase>`
   (síncrono — a fase de processamento é CPU-bound pura). É avaliado como tear-off no isolate
   principal e passado a `_runStage`, que o executa direto ou em `Isolate.run`.
6. O consumidor trata `ReturnSuccessOrError<TypeUsecase>` com `switch` exaustivo.

### Execução em `Isolate` (`runInIsolate`)

Com `runInIsolate: true` no construtor, **apenas o `process` (fase 3)** é delegado a
`Isolate.run` (via o helper privado `_runStage`), convertendo qualquer falha do isolate em
`ErrorReturn` com o código `Cod. IsolateCatch`. O **fetch do datasource (fase 1) roda sempre
no isolate principal**.

A chave para isso funcionar com datasources que seguram recursos nativos é que o `process` é
**estático** e avaliado como tear-off **antes** de entrar no `Isolate.run` — então a closure
`() => process(raw, parameters)` captura apenas a função estática, o dado bruto e os
parâmetros (todos *sendable*), e **nunca** o `this`/`_datasource`. Restrição: o dado bruto
(entrada) e o resultado (saída) precisam ser *sendable*.

### Medição de tempo (`monitorExecutionTime`)

A medição é **opcional e desligada por padrão**. Só quando o construtor recebe
`monitorExecutionTime: true` o `call` envolve a execução em um `Stopwatch` e loga o tempo via
`dart:developer`. Quando `false` (padrão), não há `Stopwatch` nem `log` — custo zero em
produção. A escolha é explícita do desenvolvedor: ligue apenas ao perfilar o usecase.

## Decisões de design

- **Tipo selado em vez de `Either`/exceptions.** O `sealed class` faz o compilador exigir o
  tratamento dos dois casos; não há caminho "esquecido".
- **Cada caso guarda o próprio campo.** A base é sem estado (só o contrato `Object? get result`);
  `SuccessReturn` guarda `_success` (`final`, tipo `R`) e `ErrorReturn` guarda `_error` (`final`,
  `AppError`), ambos recebidos por **private named parameter** (Dart 3.12,
  `const SuccessReturn({required this._success})`). Cada subclasse expõe um getter `result`
  tipado (`R` em `SuccessReturn`, `AppError` em `ErrorReturn`). Sem nullability nem `!`: cada
  caso só conhece o seu valor.
- **Resultado imutável e comparável por valor.** O tipo selado e os dois casos são `@immutable`;
  `SuccessReturn`/`ErrorReturn` implementam `==`/`hashCode` pelo valor que carregam, facilitando
  asserts e comparações.
- **Erro imutável.** `AppError` é `@immutable`; enriquecer = `copyWith`, nunca mutar. Isso
  evita efeitos colaterais ao propagar o mesmo erro por várias camadas.
- **`ErrorGeneric` compara por valor** (`==`/`hashCode` por `message`) — previsível em
  asserts/comparações.
- **`ParametersReturnResult` é interface pura.** Só `AppError get error;`. Implementadores
  usam `implements` e declaram seus próprios dados.
- **`Unit`/`Nil` são singletons** (construtor `const` + instância `const` `unit`/`nil`) —
  a canonicalização do Dart garante identidade; representam `void` e `null` como resultados
  de sucesso.
- **Dependência única: `package:meta`** (para `@protected`/`@immutable`). Sem Flutter.

## Pontos de extensão para quem usa a lib

- Implementar `Datasource<D>` (chamada externa, `throw parameters.error` em falha).
- Implementar `ParametersReturnResult` (dados + `error`), ou usar `NoParams`.
- Implementar `AppError` (erro de domínio) ou usar `ErrorGeneric`.
- Estender `UsecaseBase<T>` (regra pura) ou `UsecaseBaseCallData<T, D>` (com datasource).

## Onde está testado

- `test/src/core/return_success_or_error_test.dart` — pattern matching, igualdade por valor,
  `toString`, singletons.
- `test/src/bases/usecase_base_test.dart` — fluxo completo (sucesso/erro/void/nil),
  enriquecimento `Cod. 02-1`, short-circuit (process não é chamado no erro do fetch),
  execução em isolate (regra pura e com datasource *sendable*), `Cod. IsolateCatch`.
- `test/src/interfaces/*` — `Datasource`, `AppError`/`ErrorGeneric` (igualdade), `NoParams`.
- `example/test/*` — features do exemplo (Fibonacci, CheckConnection, datasource fake e
  `sales_report`: paridade direto×isolate, short-circuit e comparativo de tempo).
