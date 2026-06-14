# Exemplo — return_success_or_error (Dart puro)

Exemplo **Dart puro** (sem Flutter) demonstrando o uso essencial do pacote
[`return_success_or_error`](../). Mostra que a lib roda em qualquer projeto Dart
(CLI, servidor, backend).

## O que é demonstrado

- **`UsecaseBaseCallData`** consumindo um `Datasource` — feature `check_connection`,
  nos três fluxos: sucesso, erro de negócio (offline) e exceção capturada pela fase de
  fetch da base.
- **`UsecaseBase`** (regra de negócio pura) rodando em isolate via **`runInIsolate: true`** —
  feature `fibonacci`.
- **Fetch → process** com processamento pesado em isolate — feature `sales_report`: o
  datasource devolve linhas cruas de venda e o `process` (função estática) agrega o objeto
  `SalesReport`. Mostra o comparativo direto×isolate com `monitorExecutionTime`.
- Tratamento do resultado com **`switch` exaustivo** (pattern matching).
- `ParametersReturnResult` customizado, `NoParams` e `AppError`/`ErrorGeneric` imutável.

## Estrutura (Clean Architecture)

```
lib/features/
  check_connection/
    datasources/fake_connectivity_datasource.dart   # Datasource<bool>
    domain/usecase/check_connection_usecase.dart     # UsecaseBaseCallData<String, bool>
  fibonacci/
    domain/parameters/fibonacci_parameters.dart      # ParametersReturnResult
    domain/usecase/fibonacci_usecase.dart            # UsecaseBase<int>
  sales_report/
    datasources/fake_sales_datasource.dart           # Datasource<List<Map<String, dynamic>>>
    domain/model/sales_report.dart                   # objeto de domínio processado
    domain/parameters/sales_report_parameters.dart   # ParametersReturnResult
    domain/usecase/gerar_sales_report_usecase.dart   # UsecaseBaseCallData<SalesReport, List<...>>
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
