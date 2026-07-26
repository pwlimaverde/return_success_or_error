# Exemplo — return_success_or_error (Dart puro)

Exemplo **Dart puro** (sem Flutter) demonstrando o uso essencial do pacote
[`return_success_or_error`](../). Mostra que a lib roda em qualquer projeto Dart
(CLI, servidor, backend).

## O que é demonstrado

- **As três camadas** `Datasource → Repository → Usecase` — feature `check_connection`,
  nos três desfechos: sucesso, erro de **negócio** (`ConnectionOffline`, produzido pelo
  `process`) e erro **técnico** (`ConnectionUnavailable`, traduzido pelo `mapError` do
  repositório e curto-circuitado antes do `process`).
- **Erro parametrizado e fechado por feature** — cada feature declara seus erros em uma
  hierarquia `sealed`, e o consumo é um `switch` **exaustivo, sem braço `default`**.
- **`UsecaseBase`** (regra de negócio pura) rodando em isolate via **`runInIsolate: true`**,
  com os parâmetros já tipados no `process` — feature `fibonacci`.
- **Fetch → curto-circuito → process** com processamento pesado em isolate — feature
  `sales_report`: o datasource devolve 50k linhas cruas de venda e o `process` (função
  estática) agrega o objeto `SalesReport`. Exercita os quatro desfechos: sucesso, erro de
  negócio (`EmptyPeriod`), erro técnico (`SalesSourceUnavailable`) e **bug convertido pelo
  `onUnexpected`** (`linhasCorrompidas: true` faz o cast do `process` explodir — e ainda
  assim nada propaga ao chamador).
- **Hook de observabilidade** — `GerarSalesReportUsecase` sobrescreve
  `onExecutionTimeMeasured` para imprimir o comparativo direto×isolate no console.

## Estrutura (Clean Architecture)

```
lib/features/
  check_connection/
    datasources/fake_connectivity_datasource.dart    # Datasource<bool, NoParams>
    repositories/connection_repository.dart          # RepositoryBase + mapError
    domain/errors/connection_errors.dart             # sealed ConnectionError
    domain/usecase/check_connection_usecase.dart     # UsecaseBaseCallData<String, bool, NoParams, ConnectionError>
  fibonacci/
    domain/errors/fibonacci_errors.dart              # sealed FibonacciError
    domain/parameters/fibonacci_parameters.dart      # Parameters (só dados)
    domain/usecase/fibonacci_usecase.dart            # UsecaseBase<int, FibonacciParameters, FibonacciError>
  sales_report/
    datasources/fake_sales_datasource.dart           # Datasource<List<Map<String, dynamic>>, SalesReportParameters>
    repositories/sales_repository.dart               # RepositoryBase + mapError
    domain/errors/sales_report_errors.dart           # sealed SalesReportError
    domain/model/sales_report.dart                   # objeto de domínio processado
    domain/parameters/sales_report_parameters.dart   # Parameters (só dados)
    domain/usecase/gerar_sales_report_usecase.dart   # UsecaseBaseCallData<SalesReport, List<...>, ...>
bin/example.dart                                      # ponto de entrada
```

## Como rodar

```bash
dart pub get
dart run bin/example.dart
```

## Testes

As features do exemplo são testadas em [`test/`](test/):

```bash
dart test
```
