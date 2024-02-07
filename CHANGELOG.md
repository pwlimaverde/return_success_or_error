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