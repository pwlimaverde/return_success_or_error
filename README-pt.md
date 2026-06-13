# return_success_or_error

[Read this page in English](https://github.com/pwlimaverde/return_success_or_error/blob/master/README.md)

[Leia esta página em português](https://github.com/pwlimaverde/return_success_or_error/blob/master/README-pt.md)

Um pacote **Dart** puro que abstrai e simplifica usecases, datasources, parâmetros e
tratamento de erros seguindo os princípios de Clean Architecture difundidos pelo Uncle Bob.
O resultado de qualquer chamada é encapsulado em um tipo selado `ReturnSuccessOrError<T>`,
de modo que sucesso e erro precisam sempre ser tratados explicitamente.

> É um pacote Dart puro: **não depende de Flutter** e pode ser usado em qualquer projeto Dart
> (CLI, servidor, backend), além de apps Flutter.

## Conceitos principais

| Tipo | Papel |
|------|-------|
| `ReturnSuccessOrError<T>` | Tipo de resultado selado: ou `SuccessReturn<T>` ou `ErrorReturn<T>`. |
| `SuccessReturn<T>` | Armazena o valor de sucesso, acessado por `.result` (tipo `T`). |
| `ErrorReturn<T>` | Armazena a falha, acessada por `.result` (tipo `AppError`). |
| `UsecaseBase<T>` | Regra de negócio pura, sem chamada externa. |
| `UsecaseBaseCallData<T, D>` | Regra de negócio que consome um `Datasource<D>` e retorna `T`. |
| `Datasource<D>` | Abstração da chamada externa; retorna `D` ou lança `parameters.error`. |
| `ParametersReturnResult` | Carrega os dados da chamada; exige um `AppError error`. |
| `AppError` / `ErrorGeneric` | Contrato de erro imutável / implementação padrão. |
| `NoParams` | `ParametersReturnResult` pronto para chamadas sem parâmetros extras. |
| `Unit` / `unit` | Representa `void` como resultado. |
| `Nil` / `nil` | Representa `null` como resultado. |
| `Service` | Singleton para padronizar registro de DI e inicialização paralela de serviços. |

## Instalação

```yaml
dependencies:
  return_success_or_error: ^1.0.0
```

## Tratando o resultado

`ReturnSuccessOrError<T>` é um tipo selado, então você pode tratá-lo com um `switch` exaustivo:

```dart
switch (result) {
  case SuccessReturn<String>():
    print(result.result); // valor de sucesso
  case ErrorReturn<String>():
    print(result.result.message); // AppError
}
```

Ou, de forma mais concisa, com os helpers nativos:

```dart
final message = result.fold(
  onSuccess: (value) => 'OK: $value',
  onError: (error) => 'Falha: ${error.message}',
);

if (result.isSuccess) { /* ... */ }
final valorOuNull = result.getOrNull;
```

## Parâmetros

Implemente `ParametersReturnResult` para carregar os dados de uma chamada. A única exigência
é fornecer um `AppError error`, retornado em caso de falha:

```dart
final class ParametrosFibonacci implements ParametersReturnResult {
  final int num;
  @override
  final AppError error;

  ParametrosFibonacci({
    required this.num,
    required this.error,
  });
}
```

Quando a chamada não precisa de dados extras, use `NoParams`.

## Datasource

Implemente `Datasource<D>` tipando-o com o dado a ser retornado. Envolva a lógica em um
`try/catch` e faça `throw parameters.error` em caso de falha (o `RepositoryMixin` captura):

```dart
final class ConnectivityDatasource implements Datasource<bool> {
  final Connectivity _connectivity;

  ConnectivityDatasource(this._connectivity);

  @override
  Future<bool> call(NoParams parameters) async {
    try {
      final result = await _connectivity.checkConnectivity();
      return !result.contains(ConnectivityResult.none);
    } catch (e) {
      throw parameters.error.copyWith(message: "$e");
    }
  }
}
```

> `AppError` é **imutável**: para enriquecer uma mensagem, use `copyWith(message: ...)` em vez
> de mutar o erro.

## Usecase com chamada externa de Datasource

Estenda `UsecaseBaseCallData<TypeUsecase, TypeDatasource>` — o primeiro tipo é o que o usecase
retorna, o segundo é o tipo cru devolvido pelo datasource. O datasource é passado pelo
construtor **posicional**. Dentro do `call`, use `resultDatasource(...)` e faça `switch` sobre
o retorno:

```dart
final class CheckConnectUsecase extends UsecaseBaseCallData<String, bool> {
  CheckConnectUsecase(super.datasource);

  @override
  Future<ReturnSuccessOrError<String>> call(NoParams parameters) async {
    final result = await resultDatasource(
      parameters: parameters,
      datasource: datasource,
    );

    switch (result) {
      case SuccessReturn<bool>():
        return result.result
            ? const SuccessReturn(success: "Você está conectado")
            : ErrorReturn(error: parameters.error.copyWith(message: "Você está offline"));
      case ErrorReturn<bool>():
        return ErrorReturn(error: result.result);
    }
  }
}
```

`resultDatasource(...)` executa o datasource dentro de um `try/catch` e devolve
`SuccessReturn<TypeDatasource>` ou um `ErrorReturn` cuja mensagem é enriquecida com
`parameters.error`.

## Usecase apenas com a regra de negócio

Quando não há chamada externa, estenda `UsecaseBase<TypeUsecase>`:

```dart
final class TwoPlusTwoUsecase extends UsecaseBase<int> {
  @override
  Future<ReturnSuccessOrError<int>> call(NoParams parameters) async {
    return const SuccessReturn(success: 4);
  }
}
```

## Chamando o usecase

Instancie o usecase e invoque-o com `call` (parâmetros posicionais):

```dart
final usecase = CheckConnectUsecase(ConnectivityDatasource(Connectivity()));

final data = await usecase(
  NoParams(error: const ErrorGeneric(message: "Erro de conexão")),
);

switch (data) {
  case SuccessReturn<String>():
    // data.result
  case ErrorReturn<String>():
    // data.result.message
}
```

### Executando em um isolate

Ambas as classes base expõem `callIsolate(parameters)`, que executa o `call` em um isolate de
segundo plano via `Isolate.run` e loga o tempo decorrido em builds de debug. Atenção: tudo o
que o `call` captura (o usecase e seu datasource) precisa ser "sendable" para outro isolate.

## Hierarquia de feature sugerida

```
lib/
  features/
    check_connection/
      datasources/
        connectivity_datasource.dart
      domain/
        usecase/
          check_connection_usecase.dart
  main.dart
```

## Exemplos

O diretório [`example/`](example/) contém três apps Flutter demonstrando a integração com
diferentes soluções de DI/navegação: `get`, `flutter_getit` e `flutter_modular`.

## Ambiente

- Dart SDK `^3.12.0` (usa recursos do Dart 3: sealed classes, pattern matching, class modifiers).
