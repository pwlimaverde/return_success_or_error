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

  ParametersSalvarHeader({
    required this.doc,
    required this.nome,
    required this.prioridade,
    required this.corHeader,
    required this.user,
  });

   @override
  ParametersBasic get basic => ParametersBasic(
        error: ErrorGeneric(message: "teste parrametros"),
        showRuntimeMilliseconds: true,
        nameFeature: "Teste parametros",
        isIsolate: true,
      );
}
```
Ao implementar a classe ```ParametersReturnResult```, precisa sorescrever o ```ParametersBasic```, que é o responsável pelos parametros básicos necessárrios. Nessa classe é armazenado os dados que serão consultados.

Implementa-se a chamada externa ```Datasource<Tipo>``` tipando com o dado desejado ex: ```Datasource<Stream<UserModel>>```, ex:
```
class ConnectivityDatasource
    implements Datasource<({bool conect, String typeConect})> {
  final Connectivity connectivity;
  ConnectivityDatasource({required this.connectivity});

  Future<bool> get isOnline async {
    var result = await connectivity.checkConnectivity();
    return result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet;
  }

  Future<String> get type async {
    var result = await connectivity.checkConnectivity();
    switch (result) {
      case ConnectivityResult.wifi:
        return "Conect wifi";
      case ConnectivityResult.mobile:
        return "Conect mobile";
      case ConnectivityResult.ethernet:
        return "Conect ethernet";
      default:
        return "Conect none";
    }
  }

  @override
  Future<({bool conect, String typeConect})> call(
      {required ParametersReturnResult parameters}) async {
    try {
      final resultConect = await isOnline;
      final resultType = await type;
      return (conect: resultConect, typeConect: resultType);
    } catch (e) {
      throw parameters.error..message = "$e";
    }
  }
}
```

O resultado da função ```UsecaseBase<TypeUsecase>``` ou ```UsecaseBaseCallData<TypeUsecase, TypeDatasource>``` é um: ```ReturnSuccessOrError<TypeUsecase>``` que armazena os 2 resultados possíveis: ```SuccessReturn<TypeUsecase>``` que por sua vez armazena o sucesso da chamada; ```ErrorReturn<TypeUsecase>``` que por sua vez armazena o erro da chamada:

Exemplo de recuperação da informação contida no ```ReturnSuccessOrError<TypeUsecase>```:

```final result = await value.result```
A partir do ```ReturnSuccessOrError<TypeUsecase>``` poderar ser verificado se o retorno foi sucesso ou erro, apenas verificando o swith case.

Exemplo de verificação:

```
switch (result) {
      case SuccessReturn<TypeUsecase>():
        ...
      case ErrorReturn<TypeUsecase>():
        ...
    }
```


Usecase com chamada externa de Datasource:
Extende a regra de negócio ```Usecase``` com ```UsecaseBaseCallData<TypeUsecase, TypeDatasource>``` tipando o ```UsecaseBaseCallData<TypeUsecase, TypeDatasource>``` com o dado desejado ex: ```UsecaseBaseCallData<String, ({bool conect, String typeConect})>```. Onde o primeiro tipo é o retorno que será feito pelo usecase, e o segundo é o tipo do dado que será retornado do datasource.
```
final class ChecarConeccaoUsecase
    extends UsecaseBaseCallData<String, ({bool conect, String typeConect})> {
  ChecarConeccaoUsecase({required super.datasource});

  @override
  Future<ReturnSuccessOrError<String>> call(
      {required ParametersReturnResult parameters}) async {
    final resultDatacource = await resultDatasource(
      parameters: parameters,
      datasource: super.datasource,
    );

    switch (resultDatacource) {
      case SuccessReturn<({bool conect, String typeConect})>():
        if (resultDatacource.result.conect) {
          return SuccessReturn(
            success:
                "You are conect - Type: ${resultDatacource.result.typeConect}",
          );
        } else {
          return ErrorReturn(
              error: parameters.error..message = "You are offline");
        }
      case ErrorReturn<({bool conect, String typeConect})>():
        return ErrorReturn(
            error: ErrorGeneric(message: "Error check Connectivity"));
    }
  }
}
```
A função ```resultDatasource(parameters: parameters, datasource: super.datasource)``` rertora os dados do datasouce e após isso os dados são tratados diretamente no usecase para que se transformem no tipo final esperdo.

Instanciando a Class Usecase extendida da ```UsecaseBaseCallData<TypeUsecase, TypeDatasource>``` e extratindo o resultado:
```
final checarConeccaoUsecase = ChecarConeccaoUsecase(
    datasource: ConnectivityDatasource(
      connectivity: Connectivity(),
    ),
  );

  void _checkConnection() async {
    final data = await checarConeccaoUsecase(
      parameters: NoParams(
        basic: ParametersBasic(
          error: ErrorGeneric(
            message: "Conect error",
          ),
          nameFeature: "Check Conect",
          showRuntimeMilliseconds: true,
          isIsolate: true,
        ),
      ),
    );

    switch (data) {
      case SuccessReturn<String>():
        _resultChecarConeccao = data.result;
        setState(() {});

      case ErrorReturn<String>():
        _resultChecarConeccao = data.result.message;
        setState(() {});
    }
  }
```

Usecase apenas com a regra de negócio:
Extende a regra de negócio sem chamadas externas do datasouce ```Usecase``` com ```UsecaseBase<TypeUsecase>``` tipando o ```UsecaseBase<TypeUsecase>``` com o dado desejado ex: ```UsecaseBase<String>```. Onde é tipado com o retorno que será feito pelo usecase.

```
final class ChecarTypeConeccaoUsecase extends UsecaseBase<String> {
  final Connectivity connectivity;

  ChecarTypeConeccaoUsecase({required this.connectivity});

  Future<String> get type async {
    var result = await connectivity.checkConnectivity();
    switch (result) {
      case ConnectivityResult.wifi:
        return "Conect wifi";
      case ConnectivityResult.mobile:
        return "Conect mobile";
      case ConnectivityResult.ethernet:
        return "Conect ethernet";
      default:
        return "Conect none";
    }
  }

  @override
  Future<ReturnSuccessOrError<String>> call(
      {required ParametersReturnResult parameters}) async {
    if (await type == "Conect none") {
      return ErrorReturn(
        error: ErrorGeneric(message: "You are Offline!"),
      );
    } else {
      return SuccessReturn(
        success: await type,
      );
    }
  }
}
```

A classe "ParametersReturnResult". Espera receber os parametros gerais necessários para a chamada do Usecase, juntamente com os parametros obrigatórios ParametersBasic:
```showRuntimeMilliseconds``` responsável por mostar o tempo que levou para executar a chamada em milesegundos;
```nameFeature``` responsável pela identificação da feature;
```AppError``` responsável pelo tratamento do Erro;


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