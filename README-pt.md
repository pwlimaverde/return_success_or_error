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
      throw parameters.basic.error..message = "$e";
    }
  }
}
```
Usecase:
Extende a regra de negócio ```Usecase``` com ```UsecaseBase<TypeUsecase, TypeDatasource>``` tipando o ```UsecaseBase<TypeUsecase, TypeDatasource>``` com o dado desejado ex: ```UsecaseBase<String, ({bool conect, String typeConect})>```. Onde o primeiro tipo é o retorno que será feito pelo usecase, e o segundo é o tipo do dado que será retornado do datasource.
```
final class ChecarConeccaoUsecase
    extends UsecaseBase<String, ({bool conect, String typeConect})> {
  ChecarConeccaoUsecase({required super.datasource});

  @override
  Future<({AppError? error, String? result})> call(
      {required ParametersReturnResult parameters}) async {
    final resultDatacource =
        await returResult(parameters: parameters, datasource: super.datasource);

    if (resultDatacource.result != null) {
      if (resultDatacource.result!.conect) {
        return (
          result:
              "You are conect - Type: ${resultDatacource.result!.typeConect}",
          error: null,
        );
      } else {
        return (
          result: "You are offline",
          error: parameters.basic.error..message = "You are offline",
        );
      }
    } else {
      return (
        result: null,
        error: ErrorGeneric(message: "Error check Connectivity"),
      );
    }
  }
}
```
A função ```returResult(parameters: parameters, datasource: super.datasource)``` rertora os dados do datasouce e após isso os dados são tratados diretamente no usecase para que se transforrmem no tipo final esperdo.

Instanciando a Class Usecase extendida da ```UsecaseBase<TypeUsecase, TypeDatasource>``` e extratindo o resultado:
```
final checarConeccaoUsecase = ChecarConeccaoUsecase(
    datasource: ConnectivityDatasource(
      connectivity: Connectivity(),
    ),
  );

  void _checkConnection() async {
    _value = await checarConeccaoUsecase(
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

    if (_value.result != null) {
      _result = _value.result;
      setState(() {});
    } else {
      _result = _value.error?.message;
      setState(() {});
    }
  }
```

A classe "ParametersReturnResult". Espera receber os parametros gerais necessários para a chamada do Usecase, juntamente com os parametros obrigatórios ParametersBasic:
```showRuntimeMilliseconds``` responsável por mostar o tempo que levou para executar a chamada em milesegundos;
```nameFeature``` responsável pela identificação da feature;
```AppError``` responsável pelo tratamento do Erro;

O resultado da função ```UsecaseBase<TypeUsecase, TypeDatasource>``` é um record que armazena os 2 resultados possíveis:
```result``` que por sua vez armazena o sucesso da chamada;
```error``` que por sua vez armazena o erro da chamada;


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