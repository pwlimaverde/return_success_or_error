# return_success_or_error

[Read this page in English](https://github.com/pwlimaverde/return_success_or_error/blob/master/README.md)

[Leia esta página em português](https://github.com/pwlimaverde/return_success_or_error/blob/master/README-pt.md)

Abstração de Usecase retornando sucesso ou erro de uma chamada feita pelo datasource

----

Package criado com intuito de abstrair e simplificar os usecases, repositorios, datasouces e parametros, difundidos pelo tio Bob. Onde o resultado do datasource é retornado e os erros tratados de forma simples.

Exemplo de chamada à partir de um banco de dados:

Datasourse:
A classe responsavel pela consulta, nesse caso ```ConnectivityDatasource```, precisa implementar a abstração do datasource ```Datasource<Tipo>```, que por sua vez precisa declarar o ```Tipo``` do dado a ser retornado para chegar ao resultado. ex: ```Datasource<bool>```. A classe ```ParametersReturnResult``` é uma abstração para carregar os parameters necesssários para fazer a chamada externa, ex:
```
class ParametersSalvarHeader implements ParametersReturnResult {
  final String doc;
  final String nome;
  final int prioridade;
  final Map corHeader;
  final String user;
  final String nameFeature;
  final bool showRuntimeMilliseconds;

  ParametersSalvarHeader({
    required this.doc,
    required this.nome,
    required this.prioridade,
    required this.corHeader,
    required this.user,
    required this.nameFeature,
    required this.showRuntimeMilliseconds,
  });

  @override
  AppError get error =>
      ErrorReturnResult(message: "Erro ao salvar os dados do Header");
}
```
Ao implementar a classe ```ParametersReturnResult```, precisa sorescrever o ```AppError error```, que é o responsável por identificar o erro que será apresentado em caso de erro. Nessa classe é armazenado os dados que serão consultados.

Implementa-se a chamada externa ```Datasource<Tipo>``` tipando com o dado desejado ex: ```Datasource<Stream<UserModel>>```, ex:
```
class ConnectivityDatasource implements Datasource<bool> {
  final Connectivity connectivity;
  ConnectivityDatasource({required this.connectivity});

  Future<bool> get isOnline async {
    var result = await connectivity.checkConnectivity();
    return result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile;
  }

  @override
  Future<bool> call({required ParametersReturnResult parameters}) async {
    final String messageError = parameters.error.message;
    try {
      final result = await isOnline;
      if (!result) {
        throw parameters.error..message = "Você está offline";
      }
      return result;
    } catch (e) {
      throw parameters.error
        ..message = "$messageError - Cod. 03-1 --- Catch: $e";
    }
  }
}
```
Usecase:
Extende a regra de negócio ```Usecase``` com ```UseCaseImplement<Tipo>``` tipando o ```UseCaseImplement<Tipo>``` com o dado desejado ex: ```UseCaseImplement<Stream<UserModel>>```
```
class ChecarConeccaoUsecase extends UseCaseImplement<bool> {
  final Datasource<bool> datasource;

  ChecarConeccaoUsecase({required this.datasource});
  @override
  Future<ReturnSuccessOrError<bool>> call(
      {required ParametersReturnResult parameters}) async {
    final result = await returnUseCase(
      parameters: parameters,
      datasource: datasource,
    );
    return result;
  }
}
```

Instanciando a Class UseCaseImplement<Tipo> e extratindo o resultado:
```
ReturnSuccessOrError<bool>? _value;
  bool? _result;
  final checarConeccaoUsecase = ChecarConeccaoUsecase(
    datasource: ConnectivityDatasource(
      connectivity: Connectivity(),
    ),
  );

  void _checkConnection() async {
    _value = await checarConeccaoUsecase(
      parameters: NoParams(
        error: ErrorReturnResult(
          message: "Erro de conexão",
        ),
        nameFeature: "Checar Conecção",
        showRuntimeMilliseconds: true,
      ),
    );

    _result = _value!.result;
```

A classe "ParametersReturnResult". Espera receber os parametros gerais necessários para a chamada do Usecase, juntamente com os parametros obrigatórios:
```showRuntimeMilliseconds``` responsável por mostar o tempo que levou para executar a chamada em milesegundos;
```nameFeature``` responsável pela identificação da feature;
```AppError``` responsável pelo tratamento do Erro;

O resultado da função ```UseCaseImplement<Tipo>``` é um: ```ReturnSuccessOrError<Tipo>``` que armazena os 2 resultados possíveis:
```SuccessReturn<Tipo>``` que por sua vez armazena o sucesso da chamada;
```ErrorReturn<Tipo>``` que por sua vez armazena o erro da chamada;

Exemplo de recuperação da informação contida no ```ReturnSuccessOrError<Tipo>```:

```
final result = await value.result
```

A partir do ```ReturnSuccessOrError<Tipo>``` poderar ser verificado se o retorno foi sucesso ou erro, apenas verificando o status.

Exemplo de verificação:

```
if(value.status == StatusResult.success){
  ...
}
```
```
if(value.status == StatusResult.error){
  ...
}
```

Exemplo de hierarquia de uma feature:
Chegar conexção - Checa se o dispositivo está conectado a internet e retorna um bool:

```
hierarquia:
lib:
    features:
        check_connection:
            datasouces:
                connectivity_datasource.dart
            domain:
                usecase:
                checar_coneccao_usecase.dart
    main.dart
```
----