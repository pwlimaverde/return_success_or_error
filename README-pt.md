# return_success_or_error

[Read this page in English](https://github.com/pwlimaverde/return_success_or_error/blob/master/README.md)

[Leia esta página em português](https://github.com/pwlimaverde/return_success_or_error/blob/master/README-pt.md)

Um pacote **Dart** puro que abstrai e simplifica usecases, datasources, parâmetros e
tratamento de erros seguindo os princípios de Clean Architecture difundidos pelo Uncle Bob.
O resultado de qualquer chamada é encapsulado em um tipo selado `ReturnSuccessOrError<T>`,
de modo que sucesso e erro precisam sempre ser tratados explicitamente.

> Dart puro: **não depende de Flutter** e roda em qualquer projeto Dart (CLI, servidor,
> backend), além de apps Flutter.

## Por que usar

- **Um único tipo de retorno para tudo.** Toda chamada resolve em `ReturnSuccessOrError<T>` —
  ou `SuccessReturn<T>` ou `ErrorReturn<T>`. Nenhuma exceção vazando entre camadas.
- **Erros não podem ser ignorados.** Por ser um tipo *selado*, o compilador obriga você a
  tratar os dois casos via um `switch` exaustivo.
- **Separação clara de responsabilidades.** A regra de negócio (usecase) é desacoplada da
  chamada externa (datasource); o datasource fica encapsulado e é acessado por uma única
  ponte.
- **Processamento em segundo plano opcional.** Qualquer usecase pode rodar em um isolate
  construindo-o com `runInIsolate: true`, mantendo o app fluido durante processamentos pesados.

## Conceitos centrais

| Tipo | Papel |
|------|-------|
| `ReturnSuccessOrError<T>` | Tipo de resultado selado: ou `SuccessReturn<T>` ou `ErrorReturn<T>`. |
| `SuccessReturn<T>` | Armazena o valor de sucesso, acessado por `.result` (tipo `T`). |
| `ErrorReturn<T>` | Armazena a falha, acessada por `.result` (tipo `AppError`). |
| `UsecaseBase<T>` | Regra de negócio pura, sem chamada externa. |
| `UsecaseBaseCallData<T, D>` | Regra de negócio que consome um `Datasource<D>` e retorna `T`. |
| `Datasource<D>` | Abstração da chamada externa; retorna `D` ou lança `parameters.error`. |
| `ParametersReturnResult` | Carrega os dados da chamada; deve expor um `AppError error`. |
| `AppError` / `ErrorGeneric` | Contrato de erro imutável / implementação padrão. |
| `NoParams` | `ParametersReturnResult` pronto para chamadas sem parâmetros extras. |
| `Unit` / `unit` | Representa `void` como resultado. |
| `Nil` / `nil` | Representa `null` como resultado. |

## Instalação

```yaml
dependencies:
  return_success_or_error: ^1.0.0
```

```dart
import 'package:return_success_or_error/return_success_or_error.dart';
```

## Como o fluxo funciona

Uma feature flui do usecase, opcionalmente por um datasource, de volta a um
`ReturnSuccessOrError`:

```
chamador
  │  usecase(parameters)                  // call(parameters) — posicional
  ▼
UsecaseBaseCallData.call ──► resultDatasource(parameters)   // a única ponte
                                  │   try { _datasource(parameters) }   // privado
                                  ▼
                             Datasource.call ──► throw parameters.error   (falha)
                                  │                 └► valor cru D         (sucesso)
                                  ▼
                       SuccessReturn<D> | ErrorReturn<D>   (erro enriquecido via copyWith)
  ◄───────────────────────────────┘
switch (result) { SuccessReturn / ErrorReturn }   // tratamento exaustivo no usecase
  ▼
ReturnSuccessOrError<T>   →   switch (pattern matching exaustivo)
```

Pontos-chave:

- O usecase **nunca** toca o datasource diretamente. Ele chama `resultDatasource`, o único
  lugar onde o datasource (privado) é invocado.
- O datasource sinaliza falha **lançando** `parameters.error`; o `resultDatasource` captura
  e devolve um `ErrorReturn` cuja mensagem é **enriquecida** (via `copyWith`) com o contexto
  do catch — o tipo original do erro é preservado.
- Com `runInIsolate: true` no construtor, o mesmo `call` roda em um isolate de segundo plano
  (veja [Rodando em um isolate](#rodando-em-um-isolate-de-segundo-plano)).

## Uso, passo a passo

### 1. Defina o erro — `AppError` / `ErrorGeneric`

`AppError` é o contrato de erro **imutável** (implementa `Exception`). Use o `ErrorGeneric`
padrão, ou implemente o seu. Para adicionar contexto enquanto o erro sobe pelas camadas,
nunca mute — crie uma cópia com `copyWith`:

```dart
const error = ErrorGeneric(message: "Erro de conexão");
final enriquecido = error.copyWith(message: "Erro de conexão - timeout");
```

Um erro customizado mantém o mesmo contrato:

```dart
final class ApiError implements AppError {
  @override
  final String message;
  final int statusCode;

  const ApiError({required this.message, required this.statusCode});

  @override
  ApiError copyWith({String? message}) =>
      ApiError(message: message ?? this.message, statusCode: statusCode);
}
```

> Como `AppError` é uma interface usada com `implements`, ela só obriga `message` e
> `copyWith` — não há herança de comportamento. Igualdade por valor (`==`/`hashCode`) e um
> `toString` legível **não** vêm de graça: sobrescreva-os no seu erro custom quando quiser
> compará-lo por valor (útil em testes) ou imprimi-lo de forma amigável, como o `ErrorGeneric`
> faz.

### 2. Defina os parâmetros — `ParametersReturnResult` / `NoParams`

`ParametersReturnResult` é uma interface pura: a única exigência é expor o `AppError`
retornado em caso de falha. Adicione os dados que a chamada precisar:

```dart
final class ParametrosFibonacci implements ParametersReturnResult {
  final int n;
  @override
  final AppError error;

  const ParametrosFibonacci({required this.n, required this.error});
}
```

Quando a chamada não precisa de dados extras, use `NoParams`:

```dart
final params = NoParams(error: const ErrorGeneric(message: "Erro de conexão"));
```

### 3. Defina o datasource — `Datasource<D>`

Tipe-o com o dado cru que ele retorna. Envolva a lógica em um `try/catch` e faça `throw
parameters.error` em caso de falha (o `resultDatasource` do usecase captura):

```dart
final class ConnectivityDatasource implements Datasource<bool> {
  final Connectivity _connectivity;

  const ConnectivityDatasource(this._connectivity);

  @override
  Future<bool> call(ParametersReturnResult parameters) async {
    try {
      final result = await _connectivity.checkConnectivity();
      return !result.contains(ConnectivityResult.none);
    } catch (e) {
      throw parameters.error.copyWith(message: "$e");
    }
  }
}
```

### 4. Defina o usecase

#### a) Com datasource externo — `UsecaseBaseCallData<TypeUsecase, TypeDatasource>`

`TypeUsecase` é o que o usecase retorna; `TypeDatasource` é o tipo cru do datasource. O
datasource é encaminhado pelo construtor com um **super parameter**
(`{required super.datasource}`) e mantido **privado** na classe base — a subclasse nunca o
acessa diretamente, só chama `resultDatasource(parameters)`:

```dart
final class CheckConnectUsecase extends UsecaseBaseCallData<String, bool> {
  CheckConnectUsecase({required super.datasource});

  @override
  Future<ReturnSuccessOrError<String>> call(ParametersReturnResult parameters) async {
    final result = await resultDatasource(parameters);

    return switch (result) {
      SuccessReturn<bool>() => result.result
          ? const SuccessReturn(success: "Você está conectado")
          : ErrorReturn(error: parameters.error.copyWith(message: "Você está offline")),
      ErrorReturn<bool>() => ErrorReturn(error: result.result),
    };
  }
}
```

O `resultDatasource` é `@protected` — existe apenas para as subclasses e é a única ponte
entre usecase e datasource, então as subclasses não conseguem contorná-lo.

#### b) Apenas a regra de negócio — `UsecaseBase<TypeUsecase>`

Quando não há chamada externa:

```dart
final class TwoPlusTwoUsecase extends UsecaseBase<int> {
  @override
  Future<ReturnSuccessOrError<int>> call(NoParams parameters) async {
    return const SuccessReturn(success: 4);
  }
}
```

### 5. Chame o usecase

Instancie-o e invoque-o com `call` (parâmetros posicionais):

```dart
final usecase = CheckConnectUsecase(datasource: ConnectivityDatasource(Connectivity()));

final data = await usecase(
  NoParams(error: const ErrorGeneric(message: "Erro de conexão")),
);
```

### 6. Trate o resultado

`ReturnSuccessOrError<T>` é selado, então a forma mais explícita é um `switch` exaustivo:

```dart
switch (data) {
  case SuccessReturn<String>():
    print(data.result);          // valor de sucesso (String)
  case ErrorReturn<String>():
    print(data.result.message);  // AppError
}
```

Você também pode usar patterns de desestruturação do Dart 3 para uma sintaxe mais concisa:

```dart
final message = switch (data) {
  SuccessReturn(:final result) => 'OK: $result',
  ErrorReturn(:final result) => 'Falha: ${result.message}',
};
```

### 7. Rodando em um isolate de segundo plano

Ambas as classes base aceitam `runInIsolate: true` no construtor. Quando ligado, o `call`
executa o `run` em um isolate de segundo plano via `Isolate.run`; quando desligado (padrão),
roda direto. Para medir e logar o tempo decorrido (via `dart:developer`), ligue também
`monitorExecutionTime: true` — desligado por padrão, garantindo custo zero em produção:

```dart
final usecase = MeuUsecase(runInIsolate: true, monitorExecutionTime: true);
final result = await usecase(parameters);
```

> Tudo o que o `call` captura (o usecase e seu datasource) precisa ser *sendable* para o
> outro isolate. Evite capturar objetos não-transferíveis (sockets abertos, handles de
> plugin, etc.).

### 8. Resultados sem valor — `Unit` / `Nil`

Para usecases que têm sucesso sem produzir valor, use os singletons compartilhados `unit`
(representa `void`) ou `nil` (representa `null`):

```dart
final class LogoutUsecase extends UsecaseBase<Unit> {
  @override
  Future<ReturnSuccessOrError<Unit>> call(NoParams parameters) async {
    // ... executa o efeito colateral ...
    return SuccessReturn(success: unit);
  }
}
```

## Hierarquia de feature sugerida

```
lib/
  features/
    check_connection/
      datasources/
        connectivity_datasource.dart
      domain/
        parameters/
          check_connection_parameters.dart
        usecase/
          check_connection_usecase.dart
  main.dart
```

## Exemplo

O diretório [`example/`](example/) contém um exemplo **Dart puro** (CLI) demonstrando o
pacote sem Flutter: um `UsecaseBaseCallData` consumindo um `Datasource` (sucesso, erro de
negócio e exceção capturada) e um `UsecaseBase` rodando em isolate via `runInIsolate: true`.
Rode com `dart run bin/example.dart` e os testes com `dart test`.

## Ambiente

- Dart SDK `^3.12.0` (usa recursos do Dart 3: sealed classes, pattern matching, class
  modifiers e private named parameters do Dart 3.12).
- Depende apenas de `package:meta` (para `@protected`/`@immutable`) — sem Flutter.
