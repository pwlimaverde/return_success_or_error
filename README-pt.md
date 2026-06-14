# return_success_or_error

[Read this page in English](https://github.com/pwlimaverde/return_success_or_error/blob/master/README.md)

[Leia esta página em português](https://github.com/pwlimaverde/return_success_or_error/blob/master/README-pt.md)

Um pacote **Dart** puro que abstrai e simplifica usecases, datasources, parâmetros e
tratamento de erros seguindo os princípios de Clean Architecture difundidos pelo Uncle Bob.
O resultado de qualquer chamada é encapsulado em um tipo selado `ReturnSuccessOrError<T>`,
de modo que sucesso e erro precisam sempre ser tratados explicitamente.

> Dart puro: **não depende de Flutter** e roda em qualquer projeto Dart (CLI, servidor,
> backend), além de apps Flutter.

## O Problema

Em apps construídos com Clean Architecture, cada feature segue o fluxo
**datasource → usecase → UI**. Desse modelo surgem três dores recorrentes:

1. **Processamento pesado bloqueia a UI.** Quando o usecase precisa fazer parse de
   payloads grandes, agregar milhares de linhas ou transformar estruturas complexas, o
   trabalho roda na thread principal (event loop). No Flutter, isso significa **frames
   perdidos e interfaces congeladas** — o usuário vê o app "travando" enquanto a CPU
   está ocupada.

2. **Datasources não podem simplesmente ir para um isolate de background.** Um
   datasource frequentemente segura recursos nativos — conexões de banco, sockets,
   platform channels — que **não são serializáveis** e não podem cruzar a fronteira do
   isolate. Enviar o usecase inteiro (incluindo o datasource) para `Isolate.run`
   quebra em tempo de execução.

3. **Erros vazam entre camadas.** Sem um tipo de resultado padronizado, exceções
   lançadas pelo datasource se propagam sem tratamento, misturando falhas de
   infraestrutura com erros de regra de negócio e tornando o código frágil e difícil de
   depurar.

### A solução

O `return_success_or_error` resolve os três problemas por design:

- **Tipo de resultado selado** (`ReturnSuccessOrError<T>`) — toda chamada retorna
  `SuccessReturn<T>` ou `ErrorReturn<T>`. O compilador força o tratamento exaustivo via
  `switch`; nenhuma exceção vaza silenciosamente.
- **Separação fetch/process** — a classe base orquestra a chamada do datasource
  (fetch) no **isolate principal**, mantendo os recursos nativos seguros. Apenas a
  função de processamento puro (`process`) pode opcionalmente rodar em um **isolate de
  background** via `runInIsolate: true`. Como `process` é uma função estática, ela
  nunca captura `this` nem o datasource — somente o dado bruto e o resultado cruzam a
  fronteira do isolate.
- **Short-circuit automático** — se o fetch falha, o erro é retornado imediatamente e
  a fase de processamento nem é executada, evitando trabalho desnecessário.
- **Organização por feature** — o pacote guia naturalmente a separação de cada feature
  em camadas bem definidas (`datasources/`, `domain/model/`, `domain/parameters/`,
  `domain/usecase/`). Cada peça tem responsabilidade única: o datasource faz apenas o
  I/O, o model carrega o dado processado, os parameters definem a entrada tipada e o
  usecase contém exclusivamente a regra de negócio — sem acoplamento entre eles.

#### Exemplo concreto: Sales Report

O exemplo `sales_report` ilustra o ciclo completo. Um datasource consulta o banco e
devolve **50 mil linhas cruas** de venda (fase de fetch, assíncrona, no isolate
principal). O usecase recebe essas linhas já carregadas e agrega o faturamento, ticket
médio e produto mais vendido em um objeto `SalesReport` (fase de process, CPU-bound,
opcionalmente em isolate de background). A UI nunca trava:

```
sales_report/
  datasources/
    fake_sales_datasource.dart        ← I/O: consulta o banco, devolve List<Map>
  domain/
    model/
      sales_report.dart               ← Objeto processado (imutável, sendable)
    parameters/
      sales_report_parameters.dart    ← Entrada tipada (mês, ano, AppError)
    usecase/
      gerar_sales_report_usecase.dart ← Regra de negócio: parse + agregação
```

Com `runInIsolate: true`, o processamento pesado roda em um isolate de background e a
UI permanece fluida. Com `monitorExecutionTime: true`, é possível comparar o tempo
direto vs. isolate e decidir qual caminho compensa para cada volume de dados.

## Por que usar

- **Um único tipo de retorno para tudo.** Toda chamada resolve em `ReturnSuccessOrError<T>` —
  ou `SuccessReturn<T>` ou `ErrorReturn<T>`. Nenhuma exceção vazando entre camadas.
- **Erros não podem ser ignorados.** Por ser um tipo *selado*, o compilador obriga você a
  tratar os dois casos via um `switch` exaustivo.
- **Separação clara de responsabilidades.** A regra de negócio (usecase) é desacoplada da
  chamada externa (datasource); o datasource fica encapsulado e é acessado por uma única
  ponte.
- **Processamento em segundo plano opcional.** Qualquer usecase pode rodar seu processamento
  em um isolate construindo-o com `runInIsolate: true`, mantendo o app fluido durante
  processamentos pesados — enquanto o datasource permanece seguro no isolate principal.

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
  return_success_or_error: ^2.0.0
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
UsecaseBaseCallData.call
  │  FASE 1 — fetch: _datasource(parameters)   // privado, no isolate principal
  │              └► throw parameters.error  (falha)  →  ErrorReturn<D> (Cod. 02-1)
  │              └► valor cru D            (sucesso)  →  SuccessReturn<D>
  ▼
  │  FASE 2 — short-circuit: se ErrorReturn, devolve o erro (process NÃO é chamado)
  ▼
  │  FASE 3 — process(D, parameters)           // função estática, direto ou em isolate
  ▼
ReturnSuccessOrError<T>   →   switch (pattern matching exaustivo)
```

Pontos-chave:

- A base **orquestra tudo**: chama o datasource, faz o short-circuit no erro e só então
  chama o `process` com o dado **bruto já carregado**. A subclasse implementa apenas o
  getter `process` (uma função estática) — nunca toca o datasource (privado).
- O datasource sinaliza falha **lançando** `parameters.error`; a base captura e devolve um
  `ErrorReturn` cuja mensagem é **enriquecida** (via `copyWith`) com o contexto do catch
  (`Cod. 02-1`) — o tipo original do erro é preservado.
- O fetch (fase 1) roda **sempre no isolate principal**, então datasources com recursos
  nativos (conexão de banco, socket) funcionam normalmente. Com `runInIsolate: true`, apenas
  o `process` (fase 3) roda em um isolate de segundo plano — veja
  [Rodando em um isolate](#rodando-em-um-isolate-de-segundo-plano).

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

`ParametersReturnResult` é uma interface pura: a única exigência é expor o `AppError` retornado em caso de falha. Adicione todos os dados que a chamada de API/banco ou processamento precisar:

```dart
final class SalesReportParameters implements ParametersReturnResult {
  final int mes;
  final int ano;

  @override
  final AppError error;

  const SalesReportParameters({
    required this.mes,
    required this.ano,
    required this.error,
  });
}
```

Quando a chamada não precisar de dados extras, você pode usar o `NoParams` fornecido pela lib:

```dart
final params = NoParams(error: const ErrorGeneric(message: "Erro inesperado"));
```

### 3. Defina o datasource — `Datasource<D>`

Tipe-o com o dado cru que ele retorna (por exemplo, `List<Map<String, dynamic>>` vindo do banco ou um JSON cru). Envolva a lógica em um `try/catch` e faça `throw parameters.error` em caso de falha (a fase de fetch do usecase captura automaticamente e faz o short-circuit):

```dart
final class FakeSalesDatasource implements Datasource<List<Map<String, dynamic>>> {
  const FakeSalesDatasource();

  @override
  Future<List<Map<String, dynamic>>> call(covariant SalesReportParameters parameters) async {
    try {
      // Simula uma busca no banco (I/O assíncrono que não bloqueia a UI)
      await Future.delayed(const Duration(milliseconds: 100));
      return [
        {'produto': 'Produto A', 'quantidade': 10, 'valor_unitario': 50.0},
        {'produto': 'Produto B', 'quantidade': 5, 'valor_unitario': 100.0},
      ];
    } catch (e) {
      throw parameters.error.copyWith(message: "$e");
    }
  }
}
```

### 4. Defina o usecase

#### a) Com datasource externo — `UsecaseBaseCallData<TypeUsecase, TypeDatasource>`

`TypeUsecase` é o tipo do objeto de domínio processado que o usecase retorna; `TypeDatasource` é o tipo cru do datasource. O datasource é encaminhado pelo construtor com um **super parameter** (`{required super.datasource}`) e mantido **privado** na classe base.

A subclasse implementa apenas o getter `process`, apontando para uma função **estática** que recebe o dado bruto já carregado (a base faz o fetch e trata o short-circuit no erro do fetch):

```dart
final class GerarSalesReportUsecase
    extends UsecaseBaseCallData<SalesReport, List<Map<String, dynamic>>> {
  GerarSalesReportUsecase({
    required super.datasource,
    super.runInIsolate,
    super.monitorExecutionTime,
  });

  @override
  ProcessData<SalesReport, List<Map<String, dynamic>>> get process => _process;

  // Função estática: essencial para não capturar "this" e poder rodar no Isolate.
  static ReturnSuccessOrError<SalesReport> _process(
    List<Map<String, dynamic>> linhas,
    ParametersReturnResult parameters,
  ) {
    if (linhas.isEmpty) {
      return ErrorReturn(
        error: parameters.error.copyWith(message: "Sem vendas no período"),
      );
    }

    var faturamento = 0.0;
    var itens = 0;
    for (final row in linhas) {
      final quantidade = row['quantidade'] as int;
      faturamento += quantidade * (row['valor_unitario'] as double);
      itens += quantidade;
    }

    return SuccessReturn(
      success: SalesReport(
        totalItens: itens,
        faturamentoTotal: faturamento,
      ),
    );
  }
}
```

> O `process` **deve ser estático** (ou top-level): é ele que roda no isolate de background quando `runInIsolate: true`. Uma função de instância capturaria implicitamente o `this` — arrastando o datasource inteiro (e seus recursos nativos como drivers ou conexões de rede) para o isolate, o que causaria erros de compilação ou execução. Se precisar de campos específicos dos parâmetros, faça o cast de `parameters` para o seu tipo concreto dentro da função `_process`.

#### b) Apenas a regra de negócio — `UsecaseBase<TypeUsecase>`

Quando não há chamada externa de I/O, estenda `UsecaseBase` e implemente o `process` recebendo apenas os parâmetros. Por exemplo, calcular a comissão de uma venda baseada no valor total:

```dart
final class CalcularComissaoParameters implements ParametersReturnResult {
  final double valorTotal;
  @override
  final AppError error;

  const CalcularComissaoParameters({required this.valorTotal, required this.error});
}

final class CalcularComissaoUsecase extends UsecaseBase<double> {
  const CalcularComissaoUsecase({super.runInIsolate});

  @override
  ProcessPure<double> get process => _process;

  static ReturnSuccessOrError<double> _process(ParametersReturnResult parameters) {
    final params = parameters as CalcularComissaoParameters;
    return SuccessReturn(success: params.valorTotal * 0.05); // 5% de comissão
  }
}
```

### 5. Chame o usecase

Instancie-o e invoque-o passando os parâmetros concretos:

```dart
final usecase = GerarSalesReportUsecase(
  datasource: const FakeSalesDatasource(),
  runInIsolate: true, // Processamento pesado rodará em Isolate de segundo plano!
);

final data = await usecase(
  SalesReportParameters(
    mes: 6,
    ano: 2026,
    error: const ErrorGeneric(message: "Falha ao gerar relatório de vendas"),
  ),
);
```

### 6. Trate o resultado

`ReturnSuccessOrError<T>` é uma classe selada (sealed), garantindo que você trate todos os cenários de forma exaustiva com um `switch`:

```dart
switch (data) {
  case SuccessReturn<SalesReport>():
    print("Faturamento: ${data.result.faturamentoTotal}"); // valor de sucesso (SalesReport)
  case ErrorReturn<SalesReport>():
    print(data.result.message);                            // AppError
}
```

Você também pode usar as novas expressões de desestruturação e pattern matching do Dart 3 para obter um código super conciso:

```dart
final message = switch (data) {
  SuccessReturn(:final result) => 'Sucesso! Faturamento: ${result.faturamentoTotal}',
  ErrorReturn(:final result) => 'Falha: ${result.message}',
};
```

### 7. Rodando em um isolate de segundo plano

Ambas as classes base aceitam `runInIsolate: true` no construtor. Quando ligado, apenas o
`process` roda em um isolate de segundo plano via `Isolate.run`; quando desligado (padrão),
roda direto. Em `UsecaseBaseCallData`, o **fetch do datasource roda sempre no isolate
principal** — só o processamento (fase 3) vai para o isolate. Para medir e logar o tempo
decorrido (via `dart:developer`, com sufixo `(Direct)`/`(Isolate)`), ligue também
`monitorExecutionTime: true` — desligado por padrão, garantindo custo zero em produção:

```dart
final usecase = GerarSalesReportUsecase(
  datasource: const FakeSalesDatasource(),
  runInIsolate: true,
  monitorExecutionTime: true,
);
final result = await usecase(parameters);
```

> O `process` é estático, então ele **não** captura o datasource. O que cruza a fronteira do
> isolate é apenas o dado bruto (entrada) e o resultado (saída) — ambos precisam ser
> *sendable*. Por isso o datasource pode manter recursos não-transferíveis (sockets, conexões
> de banco): eles ficam no isolate principal e nunca vão para o worker.
>
> **Quando ligar:** o `Isolate.run` tem custo fixo (spawn + serialização da entrada/saída),
> que escala com o tamanho do dado. Vale para processamento **pesado** (parsing de listas
> grandes, agregações); para transformações leves, o overhead supera o ganho — deixe
> `runInIsolate: false`. Use `monitorExecutionTime` para comparar os dois caminhos.

### 8. Resultados sem valor — `Unit` / `Nil`

Para usecases que têm sucesso sem produzir valor, use os singletons compartilhados `unit`
(representa `void`) ou `nil` (representa `null`):

```dart
final class LogoutUsecase extends UsecaseBase<Unit> {
  const LogoutUsecase();

  @override
  ProcessPure<Unit> get process => _process;

  static ReturnSuccessOrError<Unit> _process(ParametersReturnResult parameters) {
    // ... executa o efeito colateral ...
    return const SuccessReturn(success: unit);
  }
}
```

## Hierarquia de feature sugerida

```
lib/
  features/
    sales_report/
      datasources/
        fake_sales_datasource.dart
      domain/
        model/
          sales_report.dart
        parameters/
          sales_report_parameters.dart
        usecase/
          gerar_sales_report_usecase.dart
  main.dart
```

## Exemplo

O diretório [`example/`](example/) contém um exemplo **Dart puro** (CLI) demonstrando o
pacote sem Flutter:

- **`check_connection`** — um `UsecaseBaseCallData` consumindo um `Datasource` (sucesso,
  erro de negócio e exceção capturada).
- **`fibonacci`** — um `UsecaseBase` rodando em isolate via `runInIsolate: true`.
- **`sales_report`** — demonstra o fluxo **fetch → process**: o datasource devolve 50k
  linhas cruas de venda (fase de fetch, isolate principal) e o `process` (função estática)
  agrega o objeto `SalesReport` (fase de processamento, isolate de background). Inclui
  `monitorExecutionTime` para comparar o tempo de execução direto vs. isolate.

Rode com `dart run bin/example.dart` e os testes com `dart test`.

## Ambiente

- Dart SDK `^3.12.0` (usa recursos do Dart 3: sealed classes, pattern matching, class
  modifiers e private named parameters do Dart 3.12).
- Depende apenas de `package:meta` (para `@protected`/`@immutable`) — sem Flutter.
