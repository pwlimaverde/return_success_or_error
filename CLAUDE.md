# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Visão geral

`return_success_or_error` é um pacote **Dart puro** (publicado no pub.dev) que fornece uma
abstração de Clean Architecture para usecases, datasources, parâmetros e tratamento de
erros. O resultado de qualquer chamada é encapsulado em um tipo selado
`ReturnSuccessOrError<T>`, que só pode ser `SuccessReturn<T>` ou `ErrorReturn<T>`,
forçando o tratamento explícito de sucesso/erro via `switch` exaustivo.

Este é um pacote-biblioteca: o código de produção vive em [lib/](lib/), não há "app"
principal a rodar. **O pacote não depende de Flutter** (usa só `dart:isolate`/`dart:async`).
Os apps em [example/](example/) demonstram integração com diferentes soluções de
DI/navegação (`get`, `flutter_getit`, `flutter_modular`) — esses sim são apps Flutter.

## Comandos

O pacote é Dart puro, então use o toolchain `dart` na raiz:

```bash
# Instalar dependências
dart pub get

# Rodar todos os testes
dart test

# Rodar um único arquivo de teste
dart test test/src/bases/usecase_base_test.dart

# Rodar um teste específico por nome (substring/regex)
dart test --name "Deve retornar um success com"

# Análise estática (lib + test; example/ e doc_dev/ são excluídos)
dart analyze
```

Para mexer nos exemplos, rode os comandos `flutter` dentro do diretório do exemplo
(ex.: `flutter analyze` em `example/example_app_flutter_get_it/`), pois cada um é um app
Flutter independente.

## Arquitetura

Tudo é exportado por [lib/return_success_or_error.dart](lib/return_success_or_error.dart);
a implementação fica em `lib/src/`. O fluxo de uma feature é:

**Usecase → (Datasource) → ReturnSuccessOrError**

### Os dois tipos de usecase ([lib/src/bases/usecase_base.dart](lib/src/bases/usecase_base.dart))

- `UsecaseBase<TypeUsecase>` — regra de negócio pura, sem chamada externa.
- `UsecaseBaseCallData<TypeUsecase, TypeDatasource>` — regra de negócio que consome um
  `Datasource`. `TypeUsecase` é o tipo retornado pelo usecase; `TypeDatasource` é o tipo
  cru devolvido pelo datasource. Recebe o datasource via construtor posicional e usa o
  `RepositoryMixin`.

Ambos são `abstract base class` (Dart 3). O `call(parameters)` posicional e o
`callIsolate(parameters)` vêm de um `base mixin` compartilhado (`_UsecaseRunner`).
`callIsolate` executa o `call` em `Isolate.run`, mede com `Stopwatch` (await antes de medir)
e loga o tempo via `dart:developer` **apenas em debug** (gated por `assert`).

### RepositoryMixin ([lib/src/mixins/repository_mixin.dart](lib/src/mixins/repository_mixin.dart))

Usado por `UsecaseBaseCallData`. `resultDatasource(...)` invoca o datasource dentro de um
`try/catch`, devolvendo `SuccessReturn` ou um `ErrorReturn` cuja mensagem é anexada à
`parameters.error`. É a única ponte entre usecase e datasource — o usecase nunca chama o
datasource diretamente; ele chama `resultDatasource` e faz `switch` no retorno.

### Datasource ([lib/src/interfaces/datasource.dart](lib/src/interfaces/datasource.dart))

`abstract interface class Datasource<TypeDatasource>` com um único `call(parameters)`.
A implementação deve envolver a lógica em `try/catch` e fazer `throw parameters.error` em
caso de falha (o `RepositoryMixin` captura).

### Parâmetros ([lib/src/interfaces/parameters.dart](lib/src/interfaces/parameters.dart))

`abstract interface class ParametersReturnResult` exige um campo `error` do tipo
`AppError`. Implemente-a para carregar os dados da chamada. `NoParams` é a implementação
pronta para quando não há parâmetros extras.

### Erros ([lib/src/interfaces/errors.dart](lib/src/interfaces/errors.dart))

`abstract interface class AppError implements Exception` — **imutável**: `String get message`
e `AppError copyWith({String? message})`. `ErrorGeneric` é a implementação concreta padrão
(`message` `final`, construtor `const`). Para enriquecer uma mensagem ao propagar o erro, use
`error.copyWith(message: ...)` (nunca mutação — o antigo `error..message = ...` não existe mais).

### Resultado ([lib/src/core/return_success_or_error.dart](lib/src/core/return_success_or_error.dart))

`sealed class ReturnSuccessOrError<R>` → `SuccessReturn<R>` (acesso via `.result`, tipo `R`)
ou `ErrorReturn<R>` (acesso via `.result`, tipo `AppError`). Por ser selada, sempre faça
`switch` exaustivo sobre os dois casos. Helpers disponíveis: `fold(onSuccess:, onError:)`,
`isSuccess`/`isError` e `getOrNull`. Para representar resultados sem valor há dois
singletons: `Unit`/`unit` (representa `void`) e `Nil`/`nil` (representa `null`).

### Auxiliares core

- `Service` ([lib/src/core/service.dart](lib/src/core/service.dart)) — singleton (`Service.to`)
  para padronizar `initDependences` (registro de DI) e `initServices` (inicialização paralela).
- `RuntimeMilliseconds` ([lib/src/core/runtime_milliseconds.dart](lib/src/core/runtime_milliseconds.dart))
  — mede tempo de execução; usado por `callIsolate`.

## Convenções importantes

- **API atual usa `call` posicional**, não nomeado. Assinatura:
  `Future<ReturnSuccessOrError<T>> call(ParametersReturnResult parameters)`. O método é
  `covariant`, então subclasses podem tipar o parâmetro com sua própria `ParametersReturnResult`.
- **Sempre trate o resultado com `switch` exaustivo** sobre `SuccessReturn<T>()` e
  `ErrorReturn<T>()` — é assim que o tipo selado garante o tratamento de erro.
- **README e testes refletem a API real** ([README.md](README.md) / [README-pt.md](README-pt.md)
  foram reescritos na v1.0.0). Mesmo assim, ao validar comportamento, [test/](test/) e
  [lib/](lib/) são a fonte de verdade.
- **Hierarquia de feature sugerida** (Clean Architecture / Uncle Bob):
  `lib/features/<feature>/datasources/` e `lib/features/<feature>/domain/usecase/`.
- Testes usam `package:test` + `mocktail` (mock de `Datasource`). Convenção de nomes de
  teste em português: `'Deve retornar um success/AppError com ...'`.
- Ambiente: Dart SDK `^3.12.0` (pacote Dart puro, sem Flutter). Depende de recursos do
  Dart 3 (sealed classes, pattern matching, `base`/`interface` modifiers, private named
  parameters do 3.12).
