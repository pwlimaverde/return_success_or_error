# Exemplo — return_success_or_error (Dart puro)

Exemplo **Dart puro** (sem Flutter) demonstrando o uso essencial do pacote
[`return_success_or_error`](../). Mostra que a lib roda em qualquer projeto Dart
(CLI, servidor, backend).

## O que é demonstrado

- **`UsecaseBaseCallData`** consumindo um `Datasource` — feature `check_connection`,
  nos três fluxos: sucesso, erro de negócio (offline) e exceção capturada por
  `resultDatasource`.
- **`UsecaseBase`** (regra de negócio pura) rodando em isolate via **`callIsolate`** —
  feature `fibonacci`.
- Tratamento do resultado com **`switch` exaustivo** e com o helper **`fold`**.
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
