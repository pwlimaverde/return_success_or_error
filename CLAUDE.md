# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Visão geral

`return_success_or_error` é um pacote **Dart puro** (publicado no pub.dev) que fornece uma
abstração de Clean Architecture para usecases, datasources, repositórios, parâmetros e
tratamento de erros. O resultado de qualquer chamada é encapsulado em um tipo selado
`ReturnSuccessOrError<TValue, TError>`, que só pode ser `Success` ou `Failure`. **O erro é
parametrizado**: cada feature declara os erros que pode produzir em uma hierarquia `sealed`
e a usa como `TError`, tornando o `switch` exaustivo **nos dois níveis** (sucesso/falha e,
dentro da falha, cada caso previsto) — sem braço `default`.

Este é um pacote-biblioteca: o código de produção vive em [lib/](lib/), não há "app"
principal a rodar. **O pacote não depende de Flutter** (usa só `dart:isolate`/`dart:async`/
`dart:developer`). O [example/](example/) é um exemplo **Dart puro** (CLI, também sem
Flutter) que demonstra o uso essencial da lib — rode com `dart run bin/example.dart` dentro
de `example/`.

A v3.0.0 é derivada da evolução da versão C# homônima
(`C:\PROJETOS\C#\PACKAGES\return-success-or-error`), adaptada ao idioma Dart. As
divergências deliberadas (cancelamento, `Match`, helpers `Ok`/`Fail`) estão registradas em
[doc_dev/arquitetura_e_fluxo.md](doc_dev/arquitetura_e_fluxo.md#paridade-com-a-versão-c).

## Comandos

O pacote é Dart puro, então use o toolchain `dart` na raiz:

```bash
# Instalar dependências
dart pub get

# Rodar todos os testes
dart test

# Rodar um único arquivo de teste
dart test test/src/usecases/usecase_base_test.dart

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
a implementação fica em `lib/src/`, em pastas espelhando a versão C#: `core/`, `errors/`,
`parameters/`, `datasources/`, `repositories/`, `usecases/`.

O fluxo de uma feature é: **Datasource → Repository → Usecase → ReturnSuccessOrError**

### Resultado ([lib/src/core/return_success_or_error.dart](lib/src/core/return_success_or_error.dart))

`sealed class ReturnSuccessOrError<TValue, TError>` → `Success<TValue, TError>` (valor em
`.value`) ou `Failure<TValue, TError>` (erro em `.error`, tipo `TError`). Em Dart os casos de
um selado genérico repetem **ambos** os parâmetros de tipo (não há como ter `Success<TValue>`
sozinho, como no `union` do C#); na prática o `TError` é inferido pelo contexto de retorno.
Consequência: o curto-circuito **reconstrói** o caso (`Failure(error)`), pois
`Failure<TData, TError>` não é um `ReturnSuccessOrError<TValue, TError>`.

A recuperação do valor é só por pattern matching — não há `fold`/`getOrNull`/`match`
(decisão deliberada: o `switch` é a forma idiomática e exaustiva em Dart). O tipo e seus
casos são `@immutable` e comparam por valor. `Unit`/`unit` (`core/unit.dart`) representa
`void` e `Nil`/`nil` (`core/nil.dart`) representa `null` como resultado válido.

### Erros ([lib/src/errors/](lib/src/errors/))

`abstract base class AppError implements Exception` — **base opcional** dos erros da feature,
com `final String message`, construtor `const` posicional, `toString`
(`"$runtimeType - $message"`) e igualdade por valor (runtimeType + message) **herdados**. É
`base` de propósito: os erros a **estendem** (nunca `implements`), o que garante que herdem o
comportamento. Subclasses com campos adicionais **devem** sobrescrever `==`/`hashCode`.
`ErrorGeneric("mensagem")` é o caso concreto pronto para o "inesperado".

`TError` **não tem bound**: herdar de `AppError` é conveniência, não obrigação.

Não existe `copyWith`: o enriquecimento automático de mensagem (`Cod. 02-1`,
`Cod. IsolateCatch`) foi removido na v3 junto com o catch genérico que o justificava.

### Parâmetros ([lib/src/parameters/](lib/src/parameters/))

`abstract base class Parameters` carrega **apenas dados** — o erro **não** vive mais nos
parâmetros. Estenda-a com campos `final` (imutável: os mesmos parâmetros podem cruzar a
fronteira do isolate). `NoParams`/`noParams` é o singleton para chamadas sem entrada.

### Datasource ([lib/src/datasources/datasource.dart](lib/src/datasources/datasource.dart))

`abstract interface class Datasource<TData, TParams extends Parameters>` com um único
`call(parameters)`. É a camada **burra**: devolve o dado bruto **ou deixa a exceção técnica
subir crua**. Sem `try/catch`, sem conhecimento de domínio.

### Repository ([lib/src/repositories/](lib/src/repositories/))

`Repository<TData, TParams, TError>` é o contrato (a abstração da qual o usecase depende —
DIP). `abstract base class RepositoryBase` é a **fronteira** (anti-corruption layer): chama
o datasource privado dentro de `try/catch` e traduz a exceção via `mapError(exception,
stackTrace, parameters)` — **abstrato**, o repositório é obrigado a mapear toda exceção para
um caso previsto de `TError`. Nenhuma exceção de infraestrutura passa daqui. O `stackTrace` é
repassado porque em Dart ele **não viaja dentro da exceção**: descartá-lo no `catch` apagaria
a origem da falha. O datasource é um
private named parameter (`{required this._datasource}`); a subclasse encaminha com
`{required super.datasource}`.

### Usecases ([lib/src/usecases/](lib/src/usecases/))

`UsecaseExecutorBase<TValue, TError>` é a base compartilhada: flags `runInIsolate` e
`monitorExecutionTime`, o `onUnexpected(exception, stackTrace)` **abstrato**, o hook virtual
`onExecutionTimeMeasured(Duration)` e os helpers `@protected` `measured`/`processStage`.

- `UsecaseBase<TValue, TParams, TError>` — regra de negócio pura. A subclasse implementa o
  getter `process` → função estática `ProcessPure<TValue, TParams, TError>`
  (`ReturnSuccessOrError<TValue, TError> Function(TParams parameters)`).
- `UsecaseBaseCallData<TValue, TData, TParams, TError>` — consome um `Repository`, recebido
  como private named parameter (`{required this._repository}`; a subclasse encaminha com
  `{required super.repository}`). A subclasse implementa `process` → função estática
  `ProcessData<TValue, TData, TParams, TError>`
  (`ReturnSuccessOrError<TValue, TError> Function(TData data, TParams parameters)`).

Ambos são `abstract base class` e expõem `call(parameters)` posicional e **tipado** (não há
mais `covariant`: `TParams` é parâmetro de tipo da classe). O fluxo de
`UsecaseBaseCallData.call` é orquestrado pela base: **(1) fetch** do repositório (no isolate
principal) → **(2) curto-circuito** automático se o fetch falhar (o `process` nem é chamado)
→ **(3) process** do dado bruto. `UsecaseBase.call` só roda a fase 3.

As duas fases são protegidas por `onUnexpected`, então **o `call` nunca propaga exceção ao
chamador**. Na fase 1 isso é só uma rede de segurança: quem estende `RepositoryBase` já
devolve `Success|Failure` e nunca lança — o `try/catch` cobre um `Repository` implementado à
mão que quebre o contrato.

Com `runInIsolate: true`, **apenas o `process` (fase 3)** roda em `Isolate.run`; o fetch roda
sempre no isolate principal. Como `process` é **estático** e avaliado como tear-off antes do
`Isolate.run`, a closure nunca captura `this`/`_repository` — por isso datasources com
recursos nativos funcionam mesmo com `runInIsolate: true`.

### A divisão do tratamento de erro (o conceito mais importante)

| Onde | O quê |
|------|-------|
| `Datasource` | Nada: a exceção técnica sobe crua. |
| `RepositoryBase.mapError` (abstrato) | Traduz a exceção técnica em um caso do `TError`. |
| `process` | Produz os erros **de negócio** (`Failure(...)` explícito). |
| `onUnexpected` (abstrato) | Converte o **inesperado** (bug no `process`, ou `Repository` que quebre o contrato) — nos **dois** modos, direto e isolate. |

`mapError` e `onUnexpected` são abstratos pelo mesmo motivo: **não existe mais erro universal
que a base possa fabricar**. Combinado ao consumo exaustivo, isso garante que tudo que as
camadas produzem está contemplado no tratamento final. O `process` **nunca** propaga exceção
ao chamador.

## Convenções importantes

- **`call` é posicional e tipado**:
  `Future<ReturnSuccessOrError<TValue, TError>> call(TParams parameters)`. A subclasse **não**
  sobrescreve `call` — implementa o getter `process` (função estática) e o `onUnexpected`.
- **`process` deve ser estático/top-level** (não captura `this`) e é **síncrono**
  (`ReturnSuccessOrError`, não `Future`): a fase de processamento é CPU-bound pura — toda
  chamada externa/assíncrona pertence ao datasource. Recebe `TParams` já tipado: **não há
  mais cast** de parâmetros dentro do `process`.
- **Sempre trate o resultado com `switch` exaustivo** sobre `Success()`/`Failure()` e, dentro
  do `Failure`, sobre cada caso do `sealed` de erros da feature — sem braço `default`.
- **Datasource e repository são encapsulados**: subclasses de `RepositoryBase` declaram
  `MyRepository({required super.datasource})` e subclasses de `UsecaseBaseCallData` declaram
  `MyUsecase({required super.repository})` — nunca acessam o campo privado da base.
- **Medição**: `monitorExecutionTime` é opt-in; o tempo vai para o hook
  `onExecutionTimeMeasured(Duration)` (padrão: `dart:developer`). A biblioteca **não usa
  `print`** — o exemplo é que sobrescreve o hook para escrever no console.
- **README e testes refletem a API real** ([README.md](README.md) / [README-pt.md](README-pt.md)
  incluem a tabela de migração v2 → v3). Ao validar comportamento, [test/](test/) e
  [lib/](lib/) são a fonte de verdade.
- **Hierarquia de feature sugerida**: `lib/features/<feature>/datasources/`,
  `repositories/`, `domain/errors/`, `domain/parameters/`, `domain/model/`,
  `domain/usecase/`.
- Testes usam `package:test` + `mocktail` (mock de `Datasource`/`Repository`), com o conjunto
  `sealed` compartilhado em [test/test_fixtures.dart](test/test_fixtures.dart). Convenção de
  nomes em português: `'Deve retornar um success/Failure com ...'`.
- Ambiente: Dart SDK `^3.12.0`. Única dependência de runtime: `package:meta`
  (`@protected`/`@immutable`). Depende de recursos do Dart 3 (sealed classes, pattern
  matching, `base`/`interface` modifiers, private named parameters do 3.12).
- **Documentação de referência**: [README.md](README.md)/[README-pt.md](README-pt.md) (uso,
  com fluxo, guia passo a passo e migração) e
  [doc_dev/arquitetura_e_fluxo.md](doc_dev/arquitetura_e_fluxo.md) (decisões de design, fluxo
  interno e paridade/divergências com a versão C#).
