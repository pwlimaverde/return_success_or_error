## [0.3.0] - 25/03/2021.

Correção de bug. Antes ´´´UseCase<Tipo> extends UseCaseImplement<tipo>´´´; Depois ´´´UseCase extends UseCaseImplement<Tipo>´´´. Documentação Corrigida.

## [0.2.0] - 25/03/2021.

**BREAKING** Acrescentado na Classe "ParametersReturnResult", a necessidade do "showRuntimeMilliseconds" e "nameFeature". Classe "ReturnResulPresenter" substituida pela inteface UseCaseImplement.

## [0.1.8] - 25/03/2021.

Documentation update.

## [0.1.7] - 19/03/2021.

Documentation update.

## [0.1.6] - 14/03/2021.

Documentation update.

## [0.1.5] - 14/03/2021.

**BREAKING** Removido a necessidade de tipar os parametros direto na classe: Antes ´´´UseCase<bool, Parameters>´´´; Depois ´´´UseCase<bool>´´´. Agora todos os ´´´Parameters´´´ precisam ser implementados de ´´´ParametersReturnResult´´´. A classe abstrata ´´´ParametersReturnResult´´´ recebe agora na implementação o ´´´AppError´´´ direto em vez da ´´´String messageError´´´. O método ´´´returnResult´´´ da classe ´´´ReturnResultUsecaseImplement´´´ foi renomeado para ´´´call´´´ e não precisa mais ser informado. 

## [0.1.4] - 14/03/2021.

Correction of readmes and exexample.

## [0.1.3] - 14/03/2021.

Correction of environment flutter >= 2.0.0.

## [0.1.2] - 14/03/2021.

**BREAKING** Correction of the class name ´´´ErroReturnResult´´´ for ´´´ErrorReturnResult´´´.

## [0.1.1] - 14/03/2021.

Correction of readmes and creation of readme-pt.md.

## [0.1.0] - 13/03/2021.

Initial release.