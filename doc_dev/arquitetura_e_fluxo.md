# Arquitetura e fluxo — `return_success_or_error`

> Referência **interna** (estado final pós-refator v1.0.0). Descreve o "porquê" de cada peça
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
| `bases/usecase_base.dart` | `UsecaseBase`, `UsecaseBaseCallData`, mixin `_UsecaseRunner` (`call`/`callIsolate`) e `resultDatasource`. |
| `interfaces/datasource.dart` | Contrato `Datasource<TypeDatasource>`. |
| `interfaces/parameters.dart` | Interface `ParametersReturnResult` + `NoParams`. |
| `interfaces/errors.dart` | Contrato imutável `AppError` + `ErrorGeneric`. |
| `core/service.dart` | Singleton `Service` (bootstrap de DI/serviços). |

Tudo é exportado por [lib/return_success_or_error.dart](../lib/return_success_or_error.dart).

## O fluxo, em detalhe

```
chamador
  │  await usecase(parameters)                    // (1) call posicional
  ▼
UsecaseBaseCallData.call(parameters)              // (2) sua regra de negócio
  │
  │  await resultDatasource(parameters)           // (3) única ponte (@protected)
  ▼
resultDatasource:
  try {
    final raw = await _datasource(parameters);    // (4) datasource privado
    return SuccessReturn(success: raw);           // (5a) sucesso cru (TypeDatasource)
  } catch (e) {
    return ErrorReturn(                            // (5b) erro enriquecido
      error: parameters.error.copyWith(
        message: "$msg - Cod. 02-1 --- Catch: $e", // preserva tipo/mensagem original
      ),
    );
  }
  │
  ▼
switch (result) {                                  // (6) usecase mapeia D -> TypeUsecase
  SuccessReturn<D>() => ... regra ...
  ErrorReturn<D>()   => ErrorReturn(...)
}
  │
  ▼
ReturnSuccessOrError<TypeUsecase>                  // (7) resultado final
  →  switch | fold | isSuccess | getOrNull | getOrElse
```

1. **`call` é posicional e `covariant`.** A assinatura na base é
   `call(covariant ParametersReturnResult parameters)`, então a subclasse pode tipar o
   parâmetro com sua própria `ParametersReturnResult` concreta.
2. A subclasse implementa a regra de negócio. Não conhece o datasource.
3. **`resultDatasource` é a única ponte** e é `@protected` (uso só por subclasses). Vive
   dentro de `UsecaseBaseCallData` — e não em um mixin separado — porque privacidade em Dart
   é **por biblioteca (arquivo)**: para enxergar o campo privado `_datasource`, o método
   precisa estar no mesmo arquivo.
4. O datasource é um **private named parameter** (Dart 3.12): construtor
   `UsecaseBaseCallData({required this._datasource})`, a subclasse encaminha com
   `{required super.datasource}`. O campo `_datasource` nunca é exposto.
5. `resultDatasource` envolve a chamada em `try/catch`:
   - sucesso → `SuccessReturn<TypeDatasource>` com o valor cru;
   - falha → `ErrorReturn` com a mensagem **enriquecida** via `parameters.error.copyWith(...)`.
     Como o `copyWith` é polimórfico, o **tipo concreto** do `AppError` é preservado (um
     `ApiError` continua `ApiError`). O código `Cod. 02-1` vem da constante
     `_datasourceCatchCode` e marca onde a falha foi capturada.
6. O usecase faz `switch` exaustivo sobre o resultado do datasource (`TypeDatasource`) e o
   mapeia para o seu próprio tipo (`TypeUsecase`).
7. O consumidor trata `ReturnSuccessOrError<TypeUsecase>` com `switch` ou helpers.

### Caminho do `callIsolate`

`callIsolate` (no mixin `_UsecaseRunner`) roda o `call` acima em `Isolate.run`, mede o tempo
com `Stopwatch` (aguardando o `await`) e loga via `dart:developer` **apenas em debug** (gate
por idiom `assert`). Restrição: tudo capturado por `call` (o usecase e seu datasource) deve
ser *sendable*. Datasources que seguram recursos não-transferíveis (sockets, handles de
plugin) não podem rodar por `callIsolate`.

## Decisões de design

- **Tipo selado em vez de `Either`/exceptions.** O `sealed class` faz o compilador exigir o
  tratamento dos dois casos; não há caminho "esquecido".
- **Campos nas subclasses, não na base.** `SuccessReturn.result` (`R`) e `ErrorReturn.result`
  (`AppError`) são campos `final` próprios — a base é sem estado. Evita os antigos campos
  nullable + operador `!`. Os construtores nomeados (`success:`/`error:`) e o getter
  `.result` foram preservados para não quebrar call sites.
- **Erro imutável.** `AppError` é `@immutable`; enriquecer = `copyWith`, nunca mutar. Isso
  evita efeitos colaterais ao propagar o mesmo erro por várias camadas.
- **`ErrorGeneric` compara por valor** (`==`/`hashCode` por `message`) — previsível em
  asserts/comparações.
- **`ParametersReturnResult` é interface pura.** Só `AppError get error;`. Implementadores
  usam `implements` e declaram seus próprios dados.
- **`Unit`/`Nil` são singletons** (`factory` + instância privada) — identidade já garante
  igualdade; representam `void` e `null` como resultados de sucesso.
- **Dependência única: `package:meta`** (para `@protected`/`@immutable`). Sem Flutter.

## Helpers de `ReturnSuccessOrError`

| Helper | Assinatura | Uso |
|--------|-----------|-----|
| `fold` | `T fold<T>({onSuccess, onError})` | Resolve os dois casos em um único valor. |
| `isSuccess` / `isError` | `bool` | Checagem rápida do caso. |
| `getOrNull` | `R?` | Valor em sucesso, `null` em erro. |
| `getOrElse` | `R getOrElse(R Function(AppError))` | Valor em sucesso, fallback em erro. |

## Pontos de extensão para quem usa a lib

- Implementar `Datasource<D>` (chamada externa, `throw parameters.error` em falha).
- Implementar `ParametersReturnResult` (dados + `error`), ou usar `NoParams`.
- Implementar `AppError` (erro de domínio) ou usar `ErrorGeneric`.
- Estender `UsecaseBase<T>` (regra pura) ou `UsecaseBaseCallData<T, D>` (com datasource).

## Onde está testado

- `test/src/core/return_success_or_error_test.dart` — `fold`/`isSuccess`/`getOrNull`/`getOrElse`,
  `toString`, singletons.
- `test/src/bases/usecase_base_test.dart` — fluxo completo (sucesso/erro/void/nil),
  enriquecimento `Cod. 02-1`, `callIsolate` (regra pura e com datasource *sendable*).
- `test/src/core/service_test.dart` — singleton, `initDependencies`, `initServices`.
- `test/src/interfaces/*` — `Datasource`, `AppError`/`ErrorGeneric` (igualdade), `NoParams`.
- `example/test/*` — features do exemplo (Fibonacci, CheckConnection, datasource fake).
