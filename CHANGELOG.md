## [1.0.0] - 13/06/2026.

Primeira versão estável. Modernização completa para Dart 3.12 / Flutter 3.44.

**BREAKING CHANGES**
1 - O pacote agora é **Dart puro**: removida a dependência de Flutter (`environment.flutter`,
    `uses-material-design`) e a dependência de `flutter_test` (testes usam `package:test`).
    Apps Flutter continuam consumindo o pacote normalmente.
2 - `AppError` agora é **imutável**: `message` passou a ser um getter (`String get message`) e
    a interface exige `AppError copyWith({String? message})`. Para enriquecer uma mensagem,
    use `error.copyWith(message: ...)` em vez de `error..message = ...`.
3 - `ErrorGeneric` agora tem `message` `final` e construtor `const`.
4 - O datasource de `UsecaseBaseCallData` agora é **privado e encapsulado**: o construtor usa
    private named parameter (`{required this._datasource}`, Dart 3.12) e as subclasses
    encaminham com `{required super.datasource}` (antes era posicional, `super.datasource`).
    `resultDatasource` deixou de receber o datasource: agora é `resultDatasource(parameters)`
    e está anotado com `@protected` (uso restrito a subclasses).
    Na DI, construa com argumento nomeado: `MyUsecase(datasource: ...)`.
5 - Removido o `RepositoryMixin` público: `resultDatasource` foi incorporado a
    `UsecaseBaseCallData` (necessário para manter o `_datasource` privado).
6 - Removido `RuntimeMilliseconds` (e seu export): era API pública órfã, sem uso na lib nem
    nos exemplos (`callIsolate` mede com `Stopwatch` próprio).
7 - `Service.initDependences` renomeado para `Service.initDependencies` (correção de typo).
8 - `ParametersReturnResult` agora é **interface pura**: expõe apenas `AppError get error`
    (removidos o campo e o construtor inertes). Implementadores continuam usando `implements`
    e declarando o próprio `error`.

**Correções**
9 - `callIsolate` corrigido: a medição de tempo aguarda o `Isolate.run` concluir (antes
    media sempre `0ms`); usa `Stopwatch` e loga via `dart:developer` apenas em debug
    (removido o `print` de produção).

**Melhorias**
10 - Novos helpers em `ReturnSuccessOrError`: `fold`, `isSuccess`, `isError` e `getOrNull`.
11 - `ReturnSuccessOrError` redesenhado: o valor passou a ser um campo da subclasse
    (`SuccessReturn.result` / `ErrorReturn.result`), eliminando os campos nullable e o
    operador `!` da classe base. Construtores (`success:`/`error:`) e `.result` preservados.
12 - `ErrorGeneric` agora compara por valor (`==`/`hashCode`), facilitando asserts e
    comparações de erro.
13 - Lógica duplicada de `callIsolate` extraída para um mixin compartilhado.
14 - Adicionado `analysis_options.yaml` (`package:lints`) com regras estritas; lib e testes
    sem issues de análise.
15 - Adicionada a dependência `meta` (para `@protected`).
16 - Dartdoc do barrel e das interfaces corrigido (referências defasadas a "presenter",
    `message` mutável e crases tipográficas `´´´`).
17 - READMEs reescritos para refletir a API real (removidos `ParametersBasic`, `call`
    nomeado, `showRuntimeMilliseconds`, `nameFeature`, `isIsolate`).
18 - Exemplos refeitos: os 3 apps Flutter (`get`/`flutter_getit`/`flutter_modular`) foram
    substituídos por um único exemplo **Dart puro** (CLI) em `example/`, coerente com a lib
    agora ser Dart puro.
19 - Cobertura de testes ampliada: `Service` (singleton, `initDependencies`, `initServices`),
    `NoParams` (erro default/custom), `toString` de `SuccessReturn`/`ErrorReturn`/`Unit`/`Nil`,
    enriquecimento de erro com `Cod. 02-1` em `resultDatasource` e `callIsolate` em
    `UsecaseBaseCallData` com datasource *sendable*. O exemplo também tem testes (`example/test/`).

## [0.19.0] - 25/04/2024. 
1 - Refatoração de callIsolate.
2 - Atualização dos examples.

## [0.18.0] - 28/04/2024. 
1 - Incluido Classe Service. Classe responsável pela padronização da inicialização dos seviços basicos.

## [0.17.0] - 01/02/2024. 
1 - Removido ```SuccessReturn<void>.voidResult()```, onde a representação do voide se dar pela class ```Unit()```, e a representação do nulo, pela class ```Nil()```.
2 - Refatoração do Exemplo, demonstrando a utilização em conjunto com Fluter_Getit.

## [0.16.1] - 24/01/2024. 
1 - Ajuste documentação

## [0.16.0] - 24/01/2024. 
1 - Remoção da interface ```Presenter```, usecase precisa ser instanciado diretamente.
2 - Refatoração do Exemplo, demonstrando a utilização em conjunto com Fluter Modular e Get.

## [0.15.1] - 23/09/2023. 
1 - Ajuste no ```Presenter```, passagem de parametros obrigatorio.

## [0.15.0] - 16/09/2023.
1 - Ajuste nos testes ```Presenter```.
2 - Passagem de Instancias diretas em vez de nomeada.

## [0.14.1] - 16/09/2023.
1 - Ajuste nos testes ```Presenter<TypeUsecase>```.

## [0.14.0] - 16/09/2023.
1 - Inclusão da inteface ```Presenter<TypeUsecase>```.

## [0.13.0] - 12/09/2023.

1 - Removido abstração do presenter(pode ser substituido por aero func conforme exemplo).
2 - Removido necessidade do ```ParametersBasic``` em ```ParametersReturnResult```, agora só é obrigatório incluir o ```AppError``` no parametros.
3 - Removido ```NoParams```, usar somente ```NoParams```.
4 - Implementado ```callIsolate``` para ```UsecaseBase``` e ```UsecaseBaseCallData```.


## [0.12.0] - 18/08/2023.

1 - Ajuste para que seja aceito ```SuccessReturn<void>```, passando um ```SuccessReturn<void>.voidResult()``` como retorno do Usecase.

## [0.11.0] - 04/08/2023.

1 - Ajuste para que seja aceito como parametos covariantes de ```ParametersReturnResult```.

## [0.10.0] - 02/07/2023.

1 - Retorno do Usecase alterado para ```ReturnSuccessOrError<TypeUsecase>```.
2 - Retorno do DatasourceMixin para ```ReturnSuccessOrError<TypeDatasource>```.
3 - Inclusão da inteface ```Presenter<TypeUsecase>```.
4 - Correção da documentação.

## [0.9.1] - 02/06/2023.

Correção da documentação.

## [0.9.0] - 02/06/2023.

1 - Usecase dividido em duas classes ```UsecaseBaseCallData``` que precisa receber um Datasource para chamada externa, e ```UsecaseBase``` que é usado para execultar a regra de negocio diretamente, sem a necessidade de Datasource.
2 - Correção da documentação.

## [0.8.0] - 28/05/2023.

1 - Alteração do nome da função ```returResult``` para ```resultDatasource```.
2 - Correção da documentação.

## [0.7.0] - 28/05/2023.

1 - Refator parar compatibilidade do dart 3.
2 - Restruturação do cógigo onde agorar será retornado um record contendo o resultado e o erro.
3 - Usecase agora processa os dados do datasource e retorna os dados separadamente. Onde é definido na extensão a tipagem do usecase e a tipagem do datasouce separadamente.
4 - Reestruturação da class base ParametersReturnResult. Onde os dados em comum serão agora ParametersBasic.

## [0.5.0] - 18/09/2022.

1 - Inclusão de isIsolate em ParametersReturnResult.
2 - Abilitação do datasource executado em isolate.
3 - Atualizaçã do Exemplo.

## [0.4.2] - 18/09/2022.

Correção do export Presenter e ajuste na documentação.

## [0.4.1] - 18/09/2022.

Inclusão da interface Presenter, classe abstrata para garantir o retorno de um ReturnSuccessOrError.

## [0.4.0] - 28/08/2022.

Refator ReturnSuccessOrError com implantação do enum StatusResult. Agora o acesso ao retorno é dado pelo ".result", e o acesso ao status é dado pelo ".status", onde retorna o enum "StatusResult.success" ou "StatusResult.error".

## [0.3.1] - 07/10/2021.

Refator interfaces e mudança dos metodos ```returnUseCase```, ```returnDatasource```, ```returnRepository``` para mixin.

## [0.3.0] - 07/10/2021.

Correção de bug. Antes ```UseCase<Tipo> extends UseCaseImplement<tipo>```; Depois ```UseCase extends UseCaseImplement<Tipo>```. Documentação Corrigida.

## [0.2.0] - 25/03/2021.

**BREAKING** Acrescentado na Classe "ParametersReturnResult", a necessidade do "showRuntimeMilliseconds" e "nameFeature". Classe "ReturnResulPresenter" substituida pela inteface UseCaseImplement.

## [0.1.8] - 25/03/2021.

Documentation update.

## [0.1.7] - 19/03/2021.

Documentation update.

## [0.1.6] - 14/03/2021.

Documentation update.

## [0.1.5] - 14/03/2021.

**BREAKING** Removido a necessidade de tipar os parametros direto na classe: Antes ```UseCase<bool, Parameters>```; Depois ```UseCase<bool>```. Agora todos os ```Parameters``` precisam ser implementados de ```ParametersReturnResult```. A classe abstrata ```ParametersReturnResult``` recebe agora na implementação o ```AppError``` direto em vez da ```String messageError```. O método ```returnResult``` da classe ```ReturnResultUsecaseImplement``` foi renomeado para ```call``` e não precisa mais ser informado. 

## [0.1.4] - 14/03/2021.

Correction of readmes and exexample.

## [0.1.3] - 14/03/2021.

Correction of environment flutter >= 2.0.0.

## [0.1.2] - 14/03/2021.

**BREAKING** Correction of the class name ```ErroReturnResult``` for ```ErrorGeneric```.

## [0.1.1] - 14/03/2021.

Correction of readmes and creation of readme-pt.md.

## [0.1.0] - 13/03/2021.

Initial release.