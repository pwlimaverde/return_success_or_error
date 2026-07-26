# Arquitetura e fluxo — `return_success_or_error`

> Referência **interna** (estado final pós-refator v3.0.0). Descreve o "porquê" de cada peça
> e como elas se conectam. Para o guia de **uso**, veja [README-pt.md](../README-pt.md).

## Objetivo

Centralizar o retorno de qualquer chamada em um único tipo selado
(`ReturnSuccessOrError<TValue, TError>`) com o **erro parametrizado e fechado por feature**,
forçando o tratamento explícito e **nominal** de cada falha possível; separar a regra de
negócio (usecase) da chamada externa (datasource) por uma fronteira que traduz exceções
(repository); e permitir isolar o processamento em uma thread (isolate).

A v3 é derivada da evolução da versão C# homônima
(`C:\PROJETOS\C#\PACKAGES\return-success-or-error`), adaptada ao idioma Dart — ver
[Paridade com a versão C#](#paridade-com-a-versão-c).

## Mapa dos arquivos (`lib/src/`)

| Arquivo | Papel |
|---------|-------|
| `core/return_success_or_error.dart` | Tipo selado `ReturnSuccessOrError<TValue, TError>` + os casos `Success`/`Failure`. |
| `core/unit.dart` / `core/nil.dart` | Singletons `unit` (void) e `nil` (null como resultado válido). |
| `errors/app_error.dart` | Base **opcional** dos erros: `message`, `toString` e igualdade por valor. |
| `errors/error_generic.dart` | `ErrorGeneric` — caso concreto pronto para o "inesperado". |
| `parameters/parameters.dart` | `Parameters` — os dados da chamada (e só dados). |
| `parameters/no_params.dart` | `NoParams` + singleton `noParams`. |
| `datasources/datasource.dart` | `Datasource<TData, TParams>` — a camada burra. |
| `repositories/repository.dart` | `Repository<TData, TParams, TError>` — o contrato do qual o usecase depende (DIP). |
| `repositories/repository_base.dart` | `RepositoryBase` — a fronteira: `try/catch` + `mapError` abstrato. |
| `usecases/usecase_executor_base.dart` | Base comum: flags, `onUnexpected`, `onExecutionTimeMeasured`, `measured`, `processStage`. |
| `usecases/usecase_base.dart` | `UsecaseBase<TValue, TParams, TError>` + typedef `ProcessPure`. |
| `usecases/usecase_base_call_data.dart` | `UsecaseBaseCallData<TValue, TData, TParams, TError>` + typedef `ProcessData`. |

Tudo é exportado por [lib/return_success_or_error.dart](../lib/return_success_or_error.dart).

## O fluxo, em detalhe

```
chamador
  │  await usecase(parameters)                      // (1) call posicional e tipado
  ▼
UsecaseBaseCallData.call(parameters)                // base orquestra tudo
  │  measured(...)                                  // (2) mede só se solicitado
  │
  │  FASE 1 — await _repository(parameters)         // (3) fetch, no isolate principal
  │    RepositoryBase.call:
  │      try   { Success(await _datasource(parameters)) }   // dado cru (TData)
  │      catch { Failure(mapError(e, stackTrace, parameters)) }  // exceção traduzida
  │    (no usecase, um try/catch de segurança manda um Repository que lance
  │     — contrato quebrado — para o onUnexpected)
  ▼
  │  FASE 2 — switch no resultado do fetch:         // (4) curto-circuito automático
  │    Failure(:final error) => Failure(error)      //     process NÃO é chamado
  │    Success(:final value) => processStage(...)
  ▼
  │  FASE 3 — processStage(() => process(value, parameters))  // (5) direto ou em isolate
  │    try   { runInIsolate ? await Isolate.run(fn) : fn() }
  │    catch { Failure(onUnexpected(exception)) }   // (6) nada propaga
  ▼
ReturnSuccessOrError<TValue, TError>                // (7) resultado final
  →  switch exaustivo nos dois níveis
```

1. **`call` é posicional e tipado.** `Future<ReturnSuccessOrError<TValue, TError>> call(TParams parameters)`.
   Não há mais `covariant`: o tipo dos parâmetros é um parâmetro de tipo da classe, então o
   `process` recebe `TParams` já concreto — o antigo `parameters as MeusParametros` dentro
   do `process` desapareceu.
2. **A medição é opt-in.** `measured` só cria o `Stopwatch` quando
   `monitorExecutionTime: true`; caso contrário delega direto.
3. **O tratamento do fetch foi para a fronteira**: o repositório já devolve
   `Success | Failure`, então o usecase não precisa traduzir nada. O `try/catch` que
   permanece no `_run` é só a **rede de segurança** para um `Repository` implementado à mão
   que quebre o contrato e lance — sem ele, a exceção escaparia do `call` e furaria a
   garantia central da lib (o chamador sempre recebe um valor). Quem estende
   `RepositoryBase` nunca chega nesse caminho.
   O repositório é um **private named parameter** (Dart 3.12) —
   `UsecaseBaseCallData({required this._repository})`, a subclasse encaminha com
   `{required super.repository}` — e nunca é exposto à subclasse.
4. **Curto-circuito automático:** se o fetch falhou, a base devolve o erro direto. O caso é
   *reconstruído* (`Failure(error)`) porque, em Dart, `Failure<TData, TError>` não é um
   `ReturnSuccessOrError<TValue, TError>` — diferente do C#, onde o `Failure<TError>` do
   `union` depende só de `TError` e flui entre os genéricos.
5. **`process` é uma função estática** (`ProcessData`/`ProcessPure`), síncrona — a fase de
   processamento é CPU-bound pura; toda chamada externa/assíncrona pertence ao datasource.
   É avaliada como tear-off no isolate principal e passada ao `processStage`.
6. **Nada propaga.** Uma exceção inesperada no `process` (um bug) vira
   `Failure(onUnexpected(e))` — nos **dois** modos, direto e isolate.
7. O consumidor trata o resultado com `switch` exaustivo em dois níveis.

### As três camadas e a divisão do tratamento de erro

| Camada | Responsabilidade no erro |
|--------|--------------------------|
| `Datasource` | **Nenhuma.** Devolve o dado bruto ou deixa a exceção técnica subir crua, com todo o contexto. |
| `RepositoryBase` | Captura e **traduz** a exceção em um caso do `TError` via `mapError` (abstrato). Nenhuma exceção de infraestrutura passa daqui. |
| `Usecase.process` | Produz os erros **de negócio** (`Failure(...)` explícito na regra). |
| `UsecaseExecutorBase` | Converte o **inesperado** (bug no `process`, ou `Repository` fora do contrato) via `onUnexpected` (abstrato). |

Ambos os hooks recebem o `StackTrace` junto da exceção. Isso é uma **divergência necessária**
em relação ao C#, onde a `Exception` já carrega o `StackTrace` dentro: em Dart o stack trace
é um segundo valor no `catch`, e uma fronteira que só repassasse a exceção **destruiria**
a informação de origem antes de chegar ao consumidor. Ignorar o parâmetro é normal; ele existe
para quem precisa reportar a falha.

`mapError` e `onUnexpected` são abstratos pelo mesmo motivo: **não existe mais um erro
universal que a base possa fabricar**. Como o consumo do resultado é exaustivo sobre
`TError`, obrigar as duas traduções garante que tudo que as camadas podem produzir está
contemplado no tratamento final.

### Execução em `Isolate` (`runInIsolate`)

Com `runInIsolate: true`, **apenas o `process` (fase 3)** é delegado a `Isolate.run`. O
**fetch (fase 1) roda sempre no isolate principal**.

A chave para isso funcionar com datasources que seguram recursos nativos é que o `process` é
**estático** e avaliado como tear-off **antes** de entrar no `Isolate.run` — então a closure
`() => process(value, parameters)` captura apenas a função estática, o dado bruto e os
parâmetros (todos *sendable*), e **nunca** o `this`/`_repository`. Restrição: o dado bruto
(entrada) e o resultado (saída) precisam ser *sendable* — e a própria falha de serialização,
se houver, chega ao `processStage` como exceção e vira `onUnexpected`.

O worker recebe `debugName: '$runtimeType.process'`, para aparecer identificado no DevTools
em vez de como um isolate anônimo.

### Medição de tempo (`monitorExecutionTime`)

Desligada por padrão — custo zero em produção. Quando ligada, o tempo total é entregue ao
hook **virtual** `onExecutionTimeMeasured(Duration)`, cuja implementação padrão escreve via
`dart:developer` (com sufixo `(Direct)`/`(Isolate)`). O consumidor sobrescreve o hook para
plugar logger ou métricas: a biblioteca não impõe dependência de logging nem imprime no
console por conta própria.

## Decisões de design

- **Erro parametrizado (`TError`) em vez de um `AppError` universal.** É a mudança central da
  v3. Um tipo de erro aberto só permite ao compilador cobrar "trate a falha"; um conjunto
  `sealed` por feature permite cobrar "trate *estas* falhas". `TError` **não tem bound**:
  pode ser qualquer tipo (a herança de `AppError` é conveniência).
- **`AppError` é `abstract base class`, não interface.** Como interface (`implements`), ela
  não entregava comportamento algum — todo erro caía na igualdade por identidade de `Object`.
  Como `base class`, o erro **estende** e herda `message`, `toString` e `==`/`hashCode`. É o
  análogo do `abstract record AppError(string Message)` do C#. O preço: subclasses com campos
  adicionais precisam sobrescrever `==`/`hashCode` (o C# ganha isso de graça do `record`).
- **`copyWith` saiu do contrato do erro.** Ele existia para o enriquecimento automático de
  mensagem (`Cod. 02-1`, `Cod. IsolateCatch`), que foi substituído por `mapError`/
  `onUnexpected`. Sem enriquecimento automático, exigir `copyWith` de todo erro seria custo
  sem contrapartida — e atrapalharia hierarquias `sealed` com campos.
- **O erro saiu dos parâmetros.** `Parameters` carrega só dados. O acoplamento antigo
  ("todo parâmetro carrega o erro que exibiria") colocava a decisão de falha no lugar
  errado: quem sabe qual erro produzir é a camada que falhou, não a entrada da chamada.
- **Camada `Repository` separada do `Datasource`.** Antes, a mesma classe fazia o I/O e
  decidia o erro (`throw parameters.error`). Separar dá: (a) datasources triviais e
  reaproveitáveis, sem conhecimento de domínio; (b) um ponto único e obrigatório de tradução;
  (c) o usecase dependendo de uma abstração (DIP), o que facilita o fake em teste.
- **`Success`/`Failure` carregam dois parâmetros de tipo.** Em Dart, os casos de um selado
  genérico repetem os parâmetros da base — não há como ter `Success<TValue>` sozinho, como no
  `union` do C#. Na prática o `TError` é inferido pelo contexto de retorno.
- **Resultado imutável e comparável por valor.** `@immutable` no selado e nos dois casos, com
  `==`/`hashCode` pelo valor carregado — asserts de teste diretos
  (`expect(result, const Success<int, MyError>(42))`).
- **`UsecaseExecutorBase` compartilhada.** Concentra flags, medição, `processStage` e
  `onUnexpected`, eliminando a duplicação entre as duas bases (o mesmo papel da
  `UsecaseExecutorBase` do C#).
- **`Unit`/`Nil` são singletons** (`const unit` / `const nil`), representando `void` e `null`
  como resultados de sucesso.
- **Dependência única: `package:meta`** (`@protected`/`@immutable`). Sem Flutter.

## Paridade com a versão C#

Portado: erro parametrizado, três camadas com `mapError` abstrato, `onUnexpected` abstrato,
parâmetros só com dados, `TParams` tipado, hook de medição, `Unit`/`Nil`, nomenclatura
(`Success`/`Failure`, `Parameters`, `NoParams`), estrutura de pastas e ordem dos parâmetros
de tipo.

Divergências **deliberadas**, por idioma da linguagem:

| Tema | C# | Dart (aqui) | Porquê |
|------|----|-------------|--------|
| Cancelamento | `CancellationToken` em toda a cadeia; OCE do chamador propaga | ausente | Dart não tem um token de cancelamento padrão na linguagem/SDK, e `Isolate.run` não é cancelável. Introduzir um tipo próprio criaria uma convenção que nada mais no ecossistema respeita. |
| Consumo do resultado | `Match(onSuccess, onError)` | só `switch` | O `switch` com pattern matching é a forma idiomática e exaustiva em Dart; um `match` seria um segundo caminho redundante (a v1 já havia removido `fold`/`getOrNull` por esse motivo). |
| Criação do resultado | conversões implícitas + helpers `Ok`/`Fail` | construtores diretos | Os helpers do C# existem para contornar o "duplo salto" de conversões implícitas, um problema que não existe em Dart. |
| Background | `Task.Run` (memória compartilhada) | `Isolate.run` (memória isolada) | Daí a exigência de `process` estático e de dados *sendable*, que o C# não tem. |
| Erro com campos | `record` dá igualdade de graça | sobrescrever `==`/`hashCode` | Dart não tem records de classe. |
| Stack trace | vai dentro da `Exception` | parâmetro extra em `mapError`/`onUnexpected` | Em Dart o stack trace é um segundo valor do `catch`; sem repassá-lo, a fronteira apagaria a origem da falha. |

## Pontos de extensão para quem usa a lib

- Declarar o `sealed` de erros da feature (opcionalmente estendendo `AppError`).
- Implementar `Datasource<TData, TParams>` (I/O puro; a exceção sobe crua).
- Estender `RepositoryBase<TData, TParams, TError>` e implementar `mapError`.
- Estender `Parameters` (dados da chamada), ou usar `noParams`.
- Estender `UsecaseBase<TValue, TParams, TError>` (regra pura) ou
  `UsecaseBaseCallData<TValue, TData, TParams, TError>` (com fonte), implementando `process`
  e `onUnexpected`.
- Opcionalmente, sobrescrever `onExecutionTimeMeasured` para a sua observabilidade.

## Onde está testado

- `test/test_fixtures.dart` — o conjunto `sealed` de erros compartilhado (`TestError`) e os
  parâmetros de teste.
- `test/src/core/return_success_or_error_test.dart` — casos, igualdade por valor, `toString`,
  consumo exaustivo nos dois níveis, `Unit`/`Nil`.
- `test/src/errors/app_error_test.dart` — comportamento herdado (`message`/`toString`/`==`),
  tipos distintos com a mesma mensagem, subclasse com campo extra.
- `test/src/parameters/parameters_test.dart` — parâmetros só com dados, `noParams`.
- `test/src/datasources/datasource_test.dart` — dado bruto e propagação da exceção crua.
- `test/src/repositories/repository_base_test.dart` — `mapError` (caso traduzido, braço
  `default`, contexto dos parâmetros) e a garantia de que nenhuma exceção escapa.
- `test/src/usecases/usecase_base_test.dart` — regra pura, erro de negócio, `onUnexpected`
  nos dois caminhos, paridade direto×isolate, `Unit`/`Nil`.
- `test/src/usecases/usecase_base_call_data_test.dart` — fetch + process, curto-circuito
  (com contagem de execuções do `process`), preservação do caso concreto, integração das três
  camadas.
- `test/src/usecases/usecase_executor_base_test.dart` — o hook de medição (chamado, não
  chamado, e no caminho isolate).
- `example/test/*` — as três features do exemplo.
