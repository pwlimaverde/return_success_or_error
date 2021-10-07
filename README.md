# return_success_or_error

[Read this page in English](https://github.com/pwlimaverde/return_success_or_error/blob/master/README.md)

[Leia esta página em português](https://github.com/pwlimaverde/return_success_or_error/blob/master/README-pt.md)

Usecase abstraction returning success or error from a call made by the data source

----

Package created in order to abstract and simplify the use cases, repositories, datasouces and parameters, disseminated by Uncle Bob. Where the result of the datasource is returned and errors are handled in a simple way.

Example of calling from a database:

Datasourse:
The class responsible for the query, in this case ```ConnectivityDatasource```, needs to implement the ```Datasource<Type>``` datasource abstraction, which in turn needs to declare the ```Type``` of the data to be returned to get the result. ex: ```Datasource<bool>```. The ```ParametersReturnResult``` class is an abstraction to load the parameters needed to make the external call, ex:

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
When implementing the ```ParametersReturnResult``` class, you need to override the ```AppError error```, which is responsible for identifying the error that will be presented in case of an error. This class stores the data that will be consulted.

The external call ```Datasource<Type>``` is implemented by typing with the desired data eg ```Datasource<Stream<UserModel>>```, ex:
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
Extend the ```Usecase``` business rule with ```UseCaseImplement<Type>``` by typing the ```UseCaseImplement<Type>``` with the desired data eg ```UseCaseImplement<Stream<UserModel>>`` `
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
Instantiating the UseCaseImplement<Type> Class and extracting the result:
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

    _result = _value!.fold(
      success: (value) => value.result,
      error: (value) => value.error,
    );
```
The "ParametersReturnResult" class. Expects to receive the general parameters necessary for the Usecase call, along with the mandatory parameters:
```showRuntimeMilliseconds``` responsible for showing the time it took to execute the call in milliseconds;
```nameFeature``` responsible for identifying the feature;
```AppError``` responsible for handling the Error;

The result of the ```UseCaseImplement<Type>``` function is a: ```ReturnSuccessOrError<Type>``` which stores the 2 possible results:
```SuccessReturn<Type>``` which in turn stores the success of the call;
```ErrorReturn<Type>``` which in turn stores the error of the call;

Example of retrieving information contained in ```ReturnSuccessOrError<Type>```:
```
final result = await value.fold(
      success: (value) => value.result,
      error: (value) => value.error,
    )
```
from ```ReturnSuccessOrError<Type>``` can be checked if the return was success or error, just by checking:
```is SuccessReturn<Type>```;
```is ErrorReturn<Type>```;

Verification example:
```
if(value is SuccessReturn<Stream<User>>){
  ...
}
```
```
if(value is ErrorReturn<Stream<User>>){
  ...
}
```
Example of a feature hierarchy:
Get connection - Checks if the device is connected to the internet and returns a bool:
```
hierarchy:
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
