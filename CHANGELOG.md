## [3.0.0] - 26/07/2026.

Reformulação do **tratamento de erro** e da **padronização do projeto**, alinhando o pacote
à evolução da versão C# homônima. O erro deixa de ser um tipo único e aberto e passa a ser
**parametrizado e fechado por feature**, com uma camada de fronteira dedicada a traduzir
falhas técnicas. O resultado: o compilador passa a cobrar o tratamento de *cada* erro
possível, e nenhuma exceção atravessa as camadas em silêncio.

**BREAKING CHANGES**

1 - `ReturnSuccessOrError<T>` agora é `ReturnSuccessOrError<TValue, TError>`. O erro é
    **parametrizado**: cada feature declara os erros que pode produzir em uma hierarquia
    `sealed` e a usa como `TError`, tornando o `switch` exaustivo **nos dois níveis**
    (sucesso/falha e, dentro da falha, cada erro previsto) — sem braço `default`.
    `TError` não tem bound: pode ser qualquer tipo.
2 - Os casos do resultado foram renomeados, alinhando à versão C#:
    `SuccessReturn(success: v)` → `Success(v)`, com o valor em `.value`;
    `ErrorReturn(error: e)` → `Failure(e)`, com o erro em `.error`.
    O getter genérico `Object? get result` da base foi removido.
3 - **Nova camada `Repository`** (`Datasource → Repository → Usecase`). O
    `RepositoryBase<TData, TParams, TError>` é a fronteira (*anti-corruption layer*):
    chama o datasource e traduz a exceção técnica via `mapError` — **abstrato**, o
    repositório é obrigado a mapear toda exceção para um erro previsto. O
    `UsecaseBaseCallData` passa a depender de `Repository` (DIP), recebido como
    `{required super.repository}` em vez de `datasource:`.
4 - `Datasource` agora é **burro**: `Datasource<TData, TParams>` devolve o dado bruto ou
    **deixa a exceção técnica subir**. O antigo `throw parameters.error` deixou de existir
    — o datasource não conhece mais o erro de domínio.
5 - **O erro saiu dos parâmetros.** `ParametersReturnResult` (que obrigava todo parâmetro a
    expor um `AppError`) foi substituído por `Parameters`, um `abstract base class` que
    carrega **só dados**. `NoParams` perdeu o parâmetro `error` e ganhou o singleton
    `noParams`.
6 - **Removido o enriquecimento automático de mensagem.** Os códigos `Cod. 02-1` (catch do
    datasource) e `Cod. IsolateCatch` (catch do isolate) não existem mais: eles existiam
    para o catch genérico que foi substituído por `mapError`/`onUnexpected`. Como
    consequência, `AppError.copyWith` saiu do contrato.
7 - `AppError` deixou de ser `abstract interface class` e virou `abstract base class` com
    `final String message`, construtor `const` posicional, `toString`
    (`"$runtimeType - $message"`) e igualdade por valor **herdados** — antes, quem usava
    `implements` não herdava comportamento nenhum. Erros com campos adicionais devem
    sobrescrever `==`/`hashCode`. `ErrorGeneric` passou a ser `ErrorGeneric("mensagem")`
    (posicional) e herda tudo da base.
8 - Novo `onUnexpected(Object exception, StackTrace stackTrace)` **abstrato** nas bases de
    usecase: uma exceção inesperada do `process` é convertida em um erro da feature. Vale
    para **os dois** caminhos (direto e isolate) — antes, só o caminho do isolate capturava,
    e o resultado era uma cópia do erro dos parâmetros.
9 - Os `process` recebem os **parâmetros já tipados** (`TParams`), eliminando o
    `parameters as MeusParametros` de dentro da função. As assinaturas passaram a ser
    `ProcessPure<TValue, TParams, TError>` e
    `ProcessData<TValue, TData, TParams, TError>`.
10 - `UsecaseBase<T>` agora é `UsecaseBase<TValue, TParams, TError>` e
    `UsecaseBaseCallData<T, D>` agora é
    `UsecaseBaseCallData<TValue, TData, TParams, TError>` (mesma ordem da versão C#).

**Melhorias**

11 - **O `StackTrace` é preservado.** `mapError(exception, stackTrace, parameters)` e
    `onUnexpected(exception, stackTrace)` recebem o stack trace junto da exceção. Em Dart, ao
    contrário do C#, o stack trace não viaja dentro da exceção — uma fronteira que só
    repassasse o objeto de erro destruiria a informação de origem antes de ela chegar ao
    consumidor. Ignorar o parâmetro é normal; ele existe para quem precisa reportar a falha
    (Sentry, Crashlytics, log estruturado).
12 - **O `call` nunca propaga exceção**, nem quando um `Repository` implementado à mão quebra
    o contrato e lança em vez de devolver `Failure`: a fase de fetch também é protegida e cai
    no `onUnexpected`. Quem estende `RepositoryBase` nunca chega nesse caminho.
13 - O isolate de processamento recebe `debugName` com o tipo do caso de uso, aparecendo
    identificado no DevTools em vez de anônimo.
14 - Nova `UsecaseExecutorBase<TValue, TError>`: base compartilhada pelos dois usecases,
    concentrando `runInIsolate`, `monitorExecutionTime`, `onUnexpected` e a medição —
    elimina a duplicação entre as duas bases.
15 - A medição de tempo agora é entregue ao hook `onExecutionTimeMeasured(Duration)`,
    sobrescrevível para plugar logger/métricas. O `print` de dentro da biblioteca foi
    removido; o padrão escreve via `dart:developer`.
16 - **Estrutura de pastas padronizada** com a versão C#: `lib/src/{core,errors,parameters,
    datasources,repositories,usecases}` (antes `lib/src/{bases,interfaces,core}`).
    `Unit` e `Nil` foram extraídos para arquivos próprios, e seus `toString` passaram a ser
    `"Unit - void"` / `"Nil - null"`.
17 - `Success`/`Failure` comparam por valor e são `@immutable`, o que simplifica asserts de
    teste (`expect(result, const Success<int, MyError>(42))`). A comparação **ignora os
    argumentos de tipo**: testá-los seria assimétrico (violando o contrato de `Object.==`),
    porque genéricos são covariantes em Dart — `Success<String, MeuErro>` é um
    `Success<String, dynamic>`, mas não o inverso. Na prática isso faz
    `expect(result, Success('x'))` funcionar, que é onde o `TError` não tem como ser inferido.
18 - Suíte de testes reescrita e ampliada (65 testes), cobrindo: tradução via `mapError`
    (incluindo braço `default`, o contexto dos parâmetros e o stack trace), curto-circuito
    sem chamar o `process`, preservação do caso concreto do erro, `onUnexpected` nos dois
    caminhos, `Repository` fora do contrato, paridade direto×isolate, o hook de medição
    (chamado e não chamado), a simetria do `==` e a exaustividade do `switch` sobre o
    conjunto fechado de erros.
19 - Exemplo refeito nas três camadas, com um conjunto `sealed` de erros por feature,
    repositórios com `mapError` e o hook de medição sobrescrito. As três features
    (`check_connection`, `fibonacci`, `sales_report`) exercitam os quatro caminhos: sucesso,
    erro de negócio (do `process`), erro técnico (do `mapError`) e bug convertido pelo
    `onUnexpected`.
20 - READMEs reescritos, com seção de migração v2 → v3.
21 - `.pubignore` mantém a documentação de desenvolvimento (`doc_dev/`, `CLAUDE.md`) fora do
    pacote publicado.

## [2.0.0] - 14/06/2026.

Reformulação do fluxo de execução dos usecases: o fetch do datasource passa a ser
totalmente orquestrado pela base, e o processamento (parsing/regra de negócio) é separado
em uma função estática que pode rodar em isolate **sem arrastar o datasource** — viabilizando
processar dados pesados em background sem travar o event loop/UI.

**BREAKING CHANGES**
1 - As subclasses não implementam mais `run(parameters)`. Agora implementam o getter
    `process`, que aponta para uma função **estática**:
    - `UsecaseBaseCallData`: `ProcessData<TypeUsecase, TypeDatasource>` —
      `ReturnSuccessOrError<TypeUsecase> Function(TypeDatasource data, ParametersReturnResult parameters)`.
      Recebe o dado **bruto já carregado** pelo datasource (sucesso desempacotado).
    - `UsecaseBase`: `ProcessPure<TypeUsecase>` —
      `ReturnSuccessOrError<TypeUsecase> Function(ParametersReturnResult parameters)`.
    O `process` deve ser estático/top-level (não captura `this`); se precisar de campos do
    parâmetro, faça o cast de `parameters` para o seu tipo concreto dentro da função.
2 - O fluxo de `UsecaseBaseCallData` agora é orquestrado pela base: **fetch** do datasource
    (no isolate principal) → **short-circuit** automático em caso de erro (o `process` nem é
    chamado) → **process** do dado bruto (direto ou em isolate). O método `resultDatasource`
    deixou de ser exposto às subclasses — a base faz o fetch internamente.
3 - `runInIsolate` agora afeta **somente o `process`** (fase 3). O fetch do datasource roda
    sempre no isolate principal, então datasources com recursos nativos (conexão de banco,
    socket) funcionam normalmente — antes, todo o `run` (incluindo o datasource) ia para o
    isolate, o que quebrava com recursos não-serializáveis.
4 - `process` é **síncrono** (`ReturnSuccessOrError`, não `Future`): reforça que a fase de
    processamento é CPU-bound pura. Toda chamada externa/assíncrona pertence ao datasource.

**Melhorias**
5 - Novos typedefs públicos `ProcessData` e `ProcessPure` documentam o contrato do `process`.
6 - `monitorExecutionTime` agora loga `(Direct)` ou `(Isolate)` para facilitar o comparativo
    entre os dois caminhos durante o desenvolvimento.
7 - Novo exemplo `sales_report` (em `example/`): datasource devolve linhas cruas de venda e o
    usecase processa o objeto `SalesReport` — em isolate quando configurado. Com testes
    (`example/test/gerar_sales_report_usecase_test.dart`) cobrindo paridade direto×isolate,
    short-circuit de erro e comparativo de tempo.

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
7 - Removido o `Service` (e seu export): singleton de bootstrap fora do escopo do pacote —
    não usava nenhum tipo da lib e seus métodos eram invólucros triviais (`await fn()` e
    `Future.wait`). O registro de DI e a inicialização de serviços voltam a ser
    responsabilidade do app consumidor.
8 - `ParametersReturnResult` agora é **interface pura**: expõe apenas `AppError get error`
    (removidos o campo e o construtor inertes). Implementadores continuam usando `implements`
    e declarando o próprio `error`.

**Correções**
9 - Execução em isolate corrigida: quando a medição está ligada
    (`monitorExecutionTime: true`), o tempo aguarda o `Isolate.run` concluir (antes media
    sempre `0ms`); usa `Stopwatch` e loga via `dart:developer` (removido o `print` de produção).

**Melhorias**
10 - `ReturnSuccessOrError` expõe `Object? get result` como contrato obrigatório: toda
    subclasse deve implementar `result`. O tipo é refinado covariantemente em cada caso
    (`R` em `SuccessReturn`, `AppError` em `ErrorReturn`). Helpers como `fold`, `isSuccess`,
    `isError`, `getOrNull` e `getOrElse` foram removidos em favor do switch exaustivo.
11 - `ReturnSuccessOrError` redesenhado: o valor passou a ser um campo da subclasse
    (`SuccessReturn._success` / `ErrorReturn._error` via private named parameters),
    eliminando os campos nullable e o operador `!` da classe base.
    Construtores (`success:`/`error:`) e `.result` preservados.
12 - `ErrorGeneric` agora compara por valor (`==`/`hashCode`), facilitando asserts e
    comparações de erro.
13 - Lógica de execução (escolha entre isolate e execução direta + medição de tempo opcional)
    centralizada no mixin compartilhado `_UsecaseRunner`, eliminando a duplicação entre as
    duas classes base.
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
19 - Cobertura de testes ampliada:
    `NoParams` (erro default/custom), `toString` de `SuccessReturn`/`ErrorReturn`/`Unit`/`Nil`,
    enriquecimento de erro com `Cod. 02-1` em `resultDatasource` e `callIsolate` em
    `UsecaseBaseCallData` com datasource *sendable*. O exemplo também tem testes (`example/test/`).
20 - `@immutable` (de `package:meta`) aplicado em `AppError`/`ErrorGeneric`,
    `ReturnSuccessOrError` (e casos), `Unit`/`Nil` e `NoParams` — o analyzer agora sinaliza
    implementações com estado mutável.
21 - Código formatado com `dart format` (estilo Dart 3.12) e documentação reescrita em
    detalhe (READMEs com fluxo e guia de uso passo a passo; `doc_dev/arquitetura_e_fluxo.md`).
22 - `AppError`: removido o `toString` da interface (era código morto — `ErrorGeneric` usa
    `implements`, que não herda comportamento, só o contrato). O dartdoc agora deixa explícito
    que `==`/`hashCode`/`toString` não são herdados e devem ser implementados no erro custom
    quando se quer igualdade por valor ou um `toString` legível. `ErrorGeneric.toString` passou
    a usar `runtimeType` (`"$runtimeType - $message"`).
23 - `NoParams`: construtor passou a ser `const` (`const NoParams({AppError? error})`),
    consistente com `@immutable` e com `ErrorGeneric`/`Unit`/`Nil`. Agora `const NoParams()` é
    canonicalizado e pode ser usado em contexto `const`. O dartdoc de `ParametersReturnResult`
    foi ampliado deixando explícito que o contrato obrigatório (`AppError get error`) garante
    que toda chamada carrega um erro tipado, sem fallback genérico vazando entre camadas.

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