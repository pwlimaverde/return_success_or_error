# return_success_or_error

[Read this page in English](https://github.com/pwlimaverde/return_success_or_error/blob/master/README.md)

[Leia esta página em português](https://github.com/pwlimaverde/return_success_or_error/blob/master/README-pt.md)

Um pacote **Dart** puro que abstrai e simplifica usecases, datasources, repositórios,
parâmetros e tratamento de erros seguindo os princípios de Clean Architecture difundidos
pelo Uncle Bob. O resultado de qualquer chamada é encapsulado em um tipo selado
`ReturnSuccessOrError<TValue, TError>`, de modo que sucesso e erro precisam sempre ser
tratados explicitamente — **e cada erro possível, nominalmente**.

> Dart puro: **não depende de Flutter** e roda em qualquer projeto Dart (CLI, servidor,
> backend), além de apps Flutter.

## O Problema

Em apps construídos com Clean Architecture, cada feature segue o fluxo
**datasource → usecase → UI**. Desse modelo surgem quatro dores recorrentes:

1. **Processamento pesado bloqueia a UI.** Quando o usecase precisa fazer parse de
   payloads grandes, agregar milhares de linhas ou transformar estruturas complexas, o
   trabalho roda na thread principal (event loop). No Flutter, isso significa **frames
   perdidos e interfaces congeladas**.

2. **Datasources não podem simplesmente ir para um isolate de background.** Um
   datasource frequentemente segura recursos nativos — conexões de banco, sockets,
   platform channels — que **não são serializáveis** e não podem cruzar a fronteira do
   isolate.

3. **Erros vazam entre camadas.** Sem um tipo de resultado padronizado, exceções
   lançadas pelo datasource se propagam sem tratamento, misturando falhas de
   infraestrutura com erros de regra de negócio.

4. **"Tratar o erro" vira tratar *um* erro genérico.** Mesmo com um tipo de resultado,
   se a falha é sempre a mesma classe aberta, o compilador não tem como saber *quais*
   erros aquela chamada produz. O tratamento degenera em `if (e is X)` espalhado, ou em
   um `catch` que engole tudo — e quando um erro novo passa a existir, nada avisa que
   falta tratá-lo.

### A solução

- **Erro parametrizado e fechado por feature** — `ReturnSuccessOrError<TValue, TError>`.
  Cada feature declara em uma hierarquia `sealed` os erros que pode produzir e a usa como
  `TError`. O `switch` fica exaustivo **nos dois níveis** (sucesso/falha e, dentro da
  falha, cada erro previsto) — **sem braço `default`**. Acrescentar um erro novo à feature
  quebra a compilação de todo consumo que não o trate: é o compilador cobrando o
  tratamento, não o code review.
- **Três camadas com uma fronteira explícita** — `Datasource → Repository → Usecase`. O
  datasource é burro (devolve dado ou lança); o `RepositoryBase` é o *anti-corruption
  layer* que traduz toda exceção técnica em um erro do domínio via `mapError`
  (**abstrato**: o compilador obriga a mapear); o usecase depende do `Repository`, nunca
  da fonte concreta.
- **Nada explode em silêncio** — se o `process` lançar uma exceção inesperada (um bug),
  ela é convertida pelo `onUnexpected` (também abstrato) em um erro previsto da feature.
  O usecase **nunca** propaga exceção ao chamador.
- **Separação fetch/process** — a base orquestra o fetch no **isolate principal**,
  mantendo os recursos nativos seguros. Apenas o `process` (função estática, CPU-bound)
  pode rodar em um **isolate de background** via `runInIsolate: true`.
- **Curto-circuito automático** — se o fetch falha, o erro é retornado imediatamente e a
  fase de processamento nem é executada.

#### Exemplo concreto: Sales Report

O exemplo `sales_report` ilustra o ciclo completo. Um datasource consulta o banco e
devolve **50 mil linhas cruas** de venda (fase de fetch, assíncrona, no isolate
principal). O repositório traduz um timeout do banco em `SalesSourceUnavailable`. O
usecase recebe as linhas já carregadas e agrega faturamento, ticket médio e produto mais
vendido em um `SalesReport` (fase de process, CPU-bound, opcionalmente em isolate):

```
sales_report/
  datasources/
    fake_sales_datasource.dart        ← I/O: consulta o banco, devolve List<Map>
  repositories/
    sales_repository.dart             ← Fronteira: mapError traduz a exceção técnica
  domain/
    errors/
      sales_report_errors.dart        ← Conjunto FECHADO de erros (sealed)
    model/
      sales_report.dart               ← Objeto processado (imutável, sendable)
    parameters/
      sales_report_parameters.dart    ← Entrada tipada (mês, ano) — só dados
    usecase/
      gerar_sales_report_usecase.dart ← Regra de negócio: parse + agregação
```

## Conceitos centrais

| Tipo | Papel |
|------|-------|
| `ReturnSuccessOrError<TValue, TError>` | Tipo de resultado selado: ou `Success` ou `Failure`. |
| `Success<TValue, TError>` | Armazena o valor de sucesso, acessado por `.value`. |
| `Failure<TValue, TError>` | Armazena a falha, acessada por `.error` (tipo `TError`). |
| `Datasource<TData, TParams>` | Chamada externa; devolve `TData` ou **lança** a exceção técnica. |
| `Repository<TData, TParams, TError>` | Contrato da camada de dados; devolve resultado já tratado. |
| `RepositoryBase<TData, TParams, TError>` | Fronteira pronta: chama a fonte e traduz via `mapError`. |
| `UsecaseBase<TValue, TParams, TError>` | Regra de negócio pura, sem fonte de dados. |
| `UsecaseBaseCallData<TValue, TData, TParams, TError>` | Regra de negócio sobre o dado do repositório. |
| `Parameters` | Os dados da chamada — **e somente dados**. |
| `NoParams` / `noParams` | Parâmetros vazios. |
| `AppError` | Base opcional dos erros: dá `message`, `toString` e igualdade por valor. |
| `ErrorGeneric` | Caso concreto pronto para o "inesperado". |
| `Unit` / `unit` | Representa `void` como resultado. |
| `Nil` / `nil` | Representa `null` como resultado. |

## Instalação

```yaml
dependencies:
  return_success_or_error: ^3.0.0
```

```dart
import 'package:return_success_or_error/return_success_or_error.dart';
```

## Como o fluxo funciona

```
chamador
  │  usecase(parameters)                       // call(parameters) — posicional
  ▼
UsecaseBaseCallData.call
  │  (mede o tempo total, se monitorExecutionTime)
  │
  │  FASE 1 — fetch: repository(parameters)         // no isolate principal
  │              │
  │              └► RepositoryBase.call
  │                   ├► datasource(parameters)  → dado cru   → Success<TData, TError>
  │                   └► exceção técnica         → mapError() → Failure<TData, TError>
  │              └► (rede de segurança: se o Repository lançar → onUnexpected)
  ▼
  │  FASE 2 — curto-circuito: se Failure, devolve o erro (process NÃO é chamado)
  ▼
  │  FASE 3 — process(data, parameters)             // função estática, direto ou em isolate
  │              └► exceção inesperada          → onUnexpected() → Failure
  ▼
ReturnSuccessOrError<TValue, TError>   →   switch exaustivo nos dois níveis
```

Pontos-chave:

- **Nenhuma exceção atravessa a fronteira.** O repositório traduz as técnicas
  (`mapError`); o executor converte as inesperadas (`onUnexpected`). Ambos são
  **abstratos**: como não existe erro universal que a base possa fabricar, é a feature que
  decide — e o compilador cobra.
- **O chamador nunca recebe um `throw`.** As duas fases são protegidas: a de processamento
  sempre, e a de fetch como rede de segurança para um `Repository` escrito à mão que
  quebre o contrato (quem estende `RepositoryBase` nunca chega lá).
- **O stack trace não se perde.** Em Dart ele não viaja dentro da exceção, então
  `mapError` e `onUnexpected` o recebem explicitamente — ignore-o em mapeamentos simples,
  use-o quando precisar reportar a falha (Sentry, Crashlytics, log estruturado).
- O fetch (fase 1) roda **sempre no isolate principal**, então datasources com recursos
  nativos funcionam normalmente. Com `runInIsolate: true`, apenas o `process` (fase 3) vai
  para o isolate.
- A subclasse do usecase fornece só o `process` (função estática) e o `onUnexpected` —
  nunca toca o repositório (privado).

## Uso, passo a passo

### 1. Declare o conjunto fechado de erros da feature

É aqui que mora a garantia. Uma hierarquia `sealed` lista todos os erros que a feature
pode produzir; estender `AppError` dá `message`, `toString` e igualdade por valor de
graça:

```dart
sealed class SalesReportError extends AppError {
  const SalesReportError(super.message);
}

/// Erro técnico traduzido pelo repositório.
final class SalesSourceUnavailable extends SalesReportError {
  const SalesSourceUnavailable(super.message);
}

/// Erro de negócio, produzido pelo process.
final class EmptyPeriod extends SalesReportError {
  const EmptyPeriod(super.message);
}

/// O inesperado — alvo do onUnexpected e do braço default do mapError.
final class SalesUnexpected extends SalesReportError {
  const SalesUnexpected(super.message);
}
```

> Estender `AppError` é **conveniência, não obrigação**: `TError` não tem bound e pode ser
> qualquer tipo (um enum, um record, uma classe sua). Se a sua subclasse acrescentar
> campos, sobrescreva `==`/`hashCode` incluindo-os — a igualdade herdada compara apenas o
> tipo e a `message`.

### 2. Defina os parâmetros — `Parameters` / `noParams`

`Parameters` carrega **apenas dados**. Mantenha-os imutáveis: os mesmos parâmetros podem
cruzar a fronteira de um isolate.

```dart
final class SalesReportParameters extends Parameters {
  final int mes;
  final int ano;

  const SalesReportParameters({required this.mes, required this.ano});
}
```

Quando a chamada não precisa de entrada, use o singleton `noParams` (do tipo `NoParams`).

### 3. Defina o datasource — `Datasource<TData, TParams>`

A camada burra: devolve o dado cru **ou deixa a exceção subir**. Sem `try/catch`, sem
conhecer o domínio.

```dart
final class FakeSalesDatasource
    implements Datasource<List<Map<String, dynamic>>, SalesReportParameters> {
  const FakeSalesDatasource();

  @override
  Future<List<Map<String, dynamic>>> call(SalesReportParameters parameters) async {
    // I/O assíncrono. Se falhar, a exceção sobe crua — quem traduz é o repositório.
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return [
      {'produto': 'Produto A', 'quantidade': 10, 'valor_unitario': 50.0},
      {'produto': 'Produto B', 'quantidade': 5, 'valor_unitario': 100.0},
    ];
  }
}
```

### 4. Defina o repositório — `RepositoryBase` e o `mapError`

A fronteira. Recebe a fonte por `{required super.datasource}` (que fica privada) e
implementa o `mapError`, traduzindo **toda** exceção em um erro previsto:

```dart
final class SalesRepository extends RepositoryBase<
    List<Map<String, dynamic>>, SalesReportParameters, SalesReportError> {
  const SalesRepository({required super.datasource});

  @override
  SalesReportError mapError(
    Object exception,
    StackTrace stackTrace,
    SalesReportParameters parameters,
  ) => switch (exception) {
    TimeoutException() => SalesSourceUnavailable(
        'Fonte indisponível para ${parameters.mes}/${parameters.ano}',
      ),
    _ => SalesUnexpected('Falha inesperada: $exception'),
  };
}
```

A partir daqui, o domínio só vê `Success | Failure` — nenhuma exceção de infraestrutura
atravessa esta linha.

> O `stackTrace` vem junto porque, em Dart, ele **não viaja dentro da exceção**: se a
> fronteira o descartasse no `catch`, a origem da falha se perderia. Ignorá-lo é normal em
> mapeamentos simples; é aqui que entra o report para o seu coletor de erros.

### 5. Defina o usecase

#### a) Com fonte de dados — `UsecaseBaseCallData<TValue, TData, TParams, TError>`

Os quatro parâmetros de tipo são, nesta ordem: o valor produzido, o dado bruto da fonte,
os parâmetros e o conjunto de erros. A subclasse fornece o `process` (função **estática**)
e o `onUnexpected`:

```dart
final class GerarSalesReportUsecase extends UsecaseBaseCallData<
    SalesReport, List<Map<String, dynamic>>, SalesReportParameters, SalesReportError> {
  const GerarSalesReportUsecase({
    required super.repository,
    super.runInIsolate,
    super.monitorExecutionTime,
  });

  @override
  ProcessData<SalesReport, List<Map<String, dynamic>>, SalesReportParameters,
      SalesReportError> get process => _process;

  @override
  SalesReportError onUnexpected(Object exception, StackTrace stackTrace) =>
      SalesUnexpected('Falha ao processar o relatório: $exception');

  // Função estática: essencial para não capturar "this" e poder rodar no Isolate.
  static ReturnSuccessOrError<SalesReport, SalesReportError> _process(
    List<Map<String, dynamic>> linhas,
    SalesReportParameters parameters, // já tipado: sem cast
  ) {
    if (linhas.isEmpty) {
      return const Failure(EmptyPeriod('Sem vendas no período'));
    }

    var faturamento = 0.0;
    var itens = 0;
    for (final row in linhas) {
      final quantidade = row['quantidade'] as int;
      faturamento += quantidade * (row['valor_unitario'] as double);
      itens += quantidade;
    }

    return Success(
      SalesReport(totalItens: itens, faturamentoTotal: faturamento),
    );
  }
}
```

> O `process` **deve ser estático** (ou top-level): é ele que roda no isolate quando
> `runInIsolate: true`. Uma função de instância capturaria implicitamente o `this` —
> arrastando o repositório e a fonte (com seus recursos nativos) para o isolate.

#### b) Apenas a regra de negócio — `UsecaseBase<TValue, TParams, TError>`

Quando não há I/O, o `process` recebe apenas os parâmetros:

```dart
final class CalcularComissaoUsecase
    extends UsecaseBase<double, ComissaoParameters, ComissaoError> {
  const CalcularComissaoUsecase({super.runInIsolate});

  @override
  ProcessPure<double, ComissaoParameters, ComissaoError> get process => _process;

  @override
  ComissaoError onUnexpected(Object exception, StackTrace stackTrace) =>
      ComissaoUnexpected('$exception');

  static ReturnSuccessOrError<double, ComissaoError> _process(
    ComissaoParameters parameters,
  ) => parameters.valorTotal < 0
      ? const Failure(ValorInvalido('valor total não pode ser negativo'))
      : Success(parameters.valorTotal * 0.05);
}
```

### 6. Chame o usecase e trate o resultado

```dart
const usecase = GerarSalesReportUsecase(
  repository: SalesRepository(datasource: FakeSalesDatasource()),
  runInIsolate: true, // o processamento pesado roda em isolate de background
);

final result = await usecase(const SalesReportParameters(mes: 6, ano: 2026));
```

O `switch` é exaustivo **nos dois níveis** — e não aceita braço `default`:

```dart
final mensagem = switch (result) {
  Success(:final value) => 'Faturamento: ${value.faturamentoTotal}',
  Failure(:final error) => switch (error) {
    SalesSourceUnavailable() => 'Fonte indisponível: ${error.message}',
    EmptyPeriod() => 'Nenhuma venda no período',
    SalesUnexpected() => 'Erro inesperado: ${error.message}',
  },
};
```

Se amanhã um `SalesMalformedData` for acrescentado ao `sealed`, **este código para de
compilar** até que o caso novo seja tratado. É essa a diferença entre "tratar o erro" e
tratar *os* erros.

> **Nos testes:** `Success` e `Failure` comparam **por valor**, então o assert é direto —
> `expect(result, Success(relatorio))` ou `expect(result, Failure(EmptyPeriod('...')))`. A
> comparação não olha os argumentos de tipo, então não é preciso anotá-los no literal.

### 7. Rodando em um isolate de segundo plano

Ambas as bases aceitam `runInIsolate: true`. Quando ligado, apenas o `process` roda em um
isolate via `Isolate.run`; o fetch permanece no isolate principal.

> **Quando ligar:** o `Isolate.run` tem custo fixo (spawn + serialização da
> entrada/saída), que escala com o tamanho do dado. Vale para processamento **pesado**
> (parsing de listas grandes, agregações); para transformações leves, o overhead supera o
> ganho. Use `monitorExecutionTime` para comparar os dois caminhos.

### 8. Observabilidade — `monitorExecutionTime` e o hook

Com `monitorExecutionTime: true`, o tempo total é medido e entregue ao hook
`onExecutionTimeMeasured`. A implementação padrão escreve via `dart:developer` (visível no
DevTools); sobrescreva para plugar o seu logger ou coletor de métricas — a biblioteca não
impõe dependência de logging:

```dart
@override
void onExecutionTimeMeasured(Duration elapsed) =>
    meuLogger.info('$runtimeType levou ${elapsed.inMilliseconds}ms');
```

Desligado por padrão: custo zero em produção.

### 9. Resultados sem valor — `Unit` / `Nil`

Para usecases que têm sucesso sem produzir valor, use os singletons `unit` (representa
`void`) ou `nil` (representa `null`):

```dart
static ReturnSuccessOrError<Unit, LogoutError> _process(NoParams parameters) {
  // ... executa o efeito colateral ...
  return const Success(unit);
}
```

## Hierarquia de feature sugerida

```
lib/
  features/
    sales_report/
      datasources/
        fake_sales_datasource.dart
      repositories/
        sales_repository.dart
      domain/
        errors/
          sales_report_errors.dart
        model/
          sales_report.dart
        parameters/
          sales_report_parameters.dart
        usecase/
          gerar_sales_report_usecase.dart
  main.dart
```

## Migrando da v2 para a v3

| v2 | v3 |
|----|----|
| `ReturnSuccessOrError<T>` | `ReturnSuccessOrError<TValue, TError>` |
| `SuccessReturn(success: v)` / `.result` | `Success(v)` / `.value` |
| `ErrorReturn(error: e)` / `.result` | `Failure(e)` / `.error` |
| `ParametersReturnResult` (obrigada a expor `AppError error`) | `Parameters` (só dados) |
| `NoParams(error: ...)` | `noParams` |
| `AppError` interface com `copyWith` | `AppError` classe base com `message`, `toString`, `==` |
| `ErrorGeneric(message: "x")` | `ErrorGeneric("x")` |
| Datasource faz `throw parameters.error` | Datasource deixa a exceção técnica subir |
| Base concatena `"Cod. 02-1"` na mensagem | `RepositoryBase.mapError` traduz (obrigatório) |
| Exceção no process vira `"Cod. IsolateCatch"` (só no isolate) | `onUnexpected` traduz (obrigatório, nos dois modos) |
| `UsecaseBaseCallData(datasource: ...)` | `UsecaseBaseCallData(repository: ...)` |
| `process` recebe `ParametersReturnResult` (exige cast) | `process` recebe `TParams` já tipado |
| `monitorExecutionTime` loga com `print` + `log` | hook `onExecutionTimeMeasured(Duration)` |

Roteiro sugerido: (1) crie o `sealed` de erros da feature; (2) tire o `error` dos
parâmetros; (3) extraia o `try/catch` do datasource para um `RepositoryBase.mapError`;
(4) troque `datasource:` por `repository:` no usecase e implemente `onUnexpected`;
(5) atualize os `switch` do consumidor para `Success`/`Failure` e cubra cada erro.

## Exemplo

O diretório [`example/`](example/) contém um exemplo **Dart puro** (CLI):

- **`check_connection`** — as três camadas completas, com erro de negócio
  (`ConnectionOffline`, do `process`) e erro técnico (`ConnectionUnavailable`, do
  `mapError`).
- **`fibonacci`** — um `UsecaseBase` puro rodando em isolate, com parâmetros tipados.
- **`sales_report`** — o fluxo **fetch → curto-circuito → process** com 50k linhas, quatro
  erros possíveis e o hook `onExecutionTimeMeasured` sobrescrito.

Rode com `dart run bin/example.dart` e os testes com `dart test`.

## Ambiente

- Dart SDK `^3.12.0` (usa recursos do Dart 3: sealed classes, pattern matching, class
  modifiers e private named parameters do Dart 3.12).
- Depende apenas de `package:meta` (para `@protected`/`@immutable`) — sem Flutter.
