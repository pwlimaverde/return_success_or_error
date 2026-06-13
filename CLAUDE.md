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
O [example/](example/) é um exemplo **Dart puro** (CLI, também sem Flutter) que demonstra o
uso essencial da lib — rode com `dart run bin/example.dart` dentro de `example/`.

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

# Formatação (estilo Dart 3.12)
dart format lib test
```

O [example/](example/) também é Dart puro: rode `dart pub get`, `dart analyze`, `dart test`
e `dart run bin/example.dart` dentro de `example/` (não precisa de Flutter). As features do
exemplo têm testes em `example/test/`.

## Arquitetura

Tudo é exportado por [lib/return_success_or_error.dart](lib/return_success_or_error.dart);
a implementação fica em `lib/src/`. O fluxo de uma feature é:

**Usecase → (Datasource) → ReturnSuccessOrError**

### Os dois tipos de usecase ([lib/src/bases/usecase_base.dart](lib/src/bases/usecase_base.dart))

- `UsecaseBase<TypeUsecase>` — regra de negócio pura, sem chamada externa.
- `UsecaseBaseCallData<TypeUsecase, TypeDatasource>` — regra de negócio que consome um
  `Datasource`. `TypeUsecase` é o tipo retornado pelo usecase; `TypeDatasource` é o tipo
  cru devolvido pelo datasource. Recebe o datasource via **private named parameter**
  (`{required this._datasource}`, Dart 3.12) — a subclasse encaminha com
  `{required super.datasource}`. O datasource fica **privado**; a subclasse não o acessa,
  só chama `resultDatasource(parameters)`.

Ambos são `abstract base class` (Dart 3). O `call(parameters)` posicional e o
`callIsolate(parameters)` vêm de um `base mixin` compartilhado (`_UsecaseRunner`).
`callIsolate` executa o `call` em `Isolate.run`, mede com `Stopwatch` (await antes de medir)
e loga o tempo via `dart:developer` **apenas em debug** (gated por `assert`).

### resultDatasource (em [lib/src/bases/usecase_base.dart](lib/src/bases/usecase_base.dart))

Método de `UsecaseBaseCallData` (não há mais um `RepositoryMixin` separado — foi
incorporado para manter o `_datasource` privado, já que privacidade em Dart é por
biblioteca). `resultDatasource(parameters)` é anotado com `@protected` (uso restrito a
subclasses) e invoca o datasource privado dentro de um `try/catch`, devolvendo `SuccessReturn`
ou um `ErrorReturn` cuja mensagem é enriquecida via `parameters.error.copyWith(...)` (o código
`Cod. 02-1` vem da constante `_datasourceCatchCode`). É a única ponte entre usecase e
datasource — o usecase nunca chama o datasource diretamente; ele chama `resultDatasource` e
faz `switch` no retorno.

### Datasource ([lib/src/interfaces/datasource.dart](lib/src/interfaces/datasource.dart))

`abstract interface class Datasource<TypeDatasource>` com um único `call(parameters)`.
A implementação deve envolver a lógica em `try/catch` e fazer `throw parameters.error` em
caso de falha (o `resultDatasource` do usecase captura).

### Parâmetros ([lib/src/interfaces/parameters.dart](lib/src/interfaces/parameters.dart))

`abstract interface class ParametersReturnResult` é uma **interface pura**: expõe apenas
`AppError get error`. Implemente-a (`implements`) declarando seu próprio `error` e os dados da
chamada. `NoParams` é a implementação pronta para quando não há parâmetros extras.

### Erros ([lib/src/interfaces/errors.dart](lib/src/interfaces/errors.dart))

`abstract interface class AppError implements Exception` — **imutável** (anotado
`@immutable`): `String get message` e `AppError copyWith({String? message})`. `ErrorGeneric`
é a implementação concreta padrão (`message` `final`, construtor `const`, compara por valor
via `==`/`hashCode`). Para enriquecer
uma mensagem ao propagar o erro, use `error.copyWith(message: ...)` (nunca mutação — o antigo
`error..message = ...` não existe mais).

### Resultado ([lib/src/core/return_success_or_error.dart](lib/src/core/return_success_or_error.dart))

`sealed class ReturnSuccessOrError<R>` → `SuccessReturn<R>` (acesso via `.result`, tipo `R`)
ou `ErrorReturn<R>` (acesso via `.result`, tipo `AppError`). Por ser selada, sempre faça
`switch` exaustivo sobre os dois casos. Helpers disponíveis: `fold(onSuccess:, onError:)`,
`isSuccess`/`isError`, `getOrNull` e `getOrElse((error) => fallback)`. Para representar
resultados sem valor há dois singletons: `Unit`/`unit` (representa `void`) e `Nil`/`nil`
(representa `null`). O tipo selado e seus casos são `@immutable` (campo `result` `final` em
cada subclasse; a base é sem estado).

### Auxiliares core

- `Service` ([lib/src/core/service.dart](lib/src/core/service.dart)) — singleton (`Service.to`)
  para padronizar `initDependencies` (registro de DI) e `initServices` (inicialização paralela).

## Convenções importantes

- **API atual usa `call` posicional**, não nomeado. Assinatura:
  `Future<ReturnSuccessOrError<T>> call(ParametersReturnResult parameters)`. O método é
  `covariant`, então subclasses podem tipar o parâmetro com sua própria `ParametersReturnResult`.
- **Sempre trate o resultado com `switch` exaustivo** sobre `SuccessReturn<T>()` e
  `ErrorReturn<T>()` — é assim que o tipo selado garante o tratamento de erro.
- **Datasource é encapsulado**: subclasses de `UsecaseBaseCallData` declaram
  `MyUsecase({required super.datasource})` e dentro do `call` usam `resultDatasource(parameters)`
  — nunca acessam o datasource diretamente (ele é privado na base). Na DI, construa com o
  argumento nomeado: `MyUsecase(datasource: ...)` (ou tear-off `.new`, que injetores como o
  auto_injector resolvem por tipo).
- **README e testes refletem a API real** ([README.md](README.md) / [README-pt.md](README-pt.md)
  foram reescritos na v1.0.0). Mesmo assim, ao validar comportamento, [test/](test/) e
  [lib/](lib/) são a fonte de verdade.
- **Hierarquia de feature sugerida** (Clean Architecture / Uncle Bob):
  `lib/features/<feature>/datasources/` e `lib/features/<feature>/domain/usecase/`.
- Testes usam `package:test` + `mocktail` (mock de `Datasource`). Convenção de nomes de
  teste em português: `'Deve retornar um success/AppError com ...'`.
- Ambiente: Dart SDK `^3.12.0` (pacote Dart puro, sem Flutter). Única dependência de runtime:
  `package:meta` (para `@protected`/`@immutable`). Depende de recursos do Dart 3 (sealed
  classes, pattern matching, `base`/`interface` modifiers, private named parameters do 3.12).
- **Documentação de referência**: [README.md](README.md)/[README-pt.md](README-pt.md) (uso,
  com fluxo e guia passo a passo) e [doc_dev/arquitetura_e_fluxo.md](doc_dev/arquitetura_e_fluxo.md)
  (decisões de design e fluxo interno).
