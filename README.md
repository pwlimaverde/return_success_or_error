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
When implementing the ```ParametersReturnResult``` class, you need to override the ```ParametersBasic```, which is responsible for the necessary basic parameters. This class stores the data to be queried.

The external call ```Datasource<Type>``` is implemented by typing with the desired data ex: ```Datasource<Stream<UserModel>>```, ex:
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

The result of function ```UsecaseBase<TypeUsecase>``` or ```UsecaseBaseCallData<TypeUsecase, TypeDatasource>``` is a: ```ReturnSuccessOrError<TypeUsecase>``` which stores the 2 possible results: ``` SuccessReturn<TypeUsecase>``` which in turn stores the success of the call; ```ErrorReturn<TypeUsecase>``` which in turn stores the error of the call:

Example of recovering the information contained in ```ReturnSuccessOrError<TypeUsecase>```:

```final result = await value.result```
From the ```ReturnSuccessOrError<TypeUsecase>``` it can be verified if the return was success or error, just checking the swith case.

Verification example:

```
switch(result) {
      case SuccessReturn<TypeUsecase>():
        ...
      case ErrorReturn<TypeUsecase>():
        ...
    }
```


Usecase with external Datasource call:
Extend the ```Usecase``` business rule with ```UsecaseBaseCallData<TypeUsecase, TypeDatasource>``` by typing the ```UsecaseBaseCallData<TypeUsecase, TypeDatasource>``` with the desired data ex: ```UsecaseBaseCallData<String, ({bool conect, String typeConect})>```. Where the first type is the return that will be made by usecase, and the second is the type of data that will be returned from the datasource.
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
The ```resultDatasource(parameters: parameters, datasource: super.datasource)``` function returns the data from the datasource and after that the data is treated directly in the usecase so that it transforms into the expected final type.

Instantiating the extended Usecase Class of ```UsecaseBaseCallData<TypeUsecase, TypeDatasource>``` and extracting the result:
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
Usecase only with the business rule:
Extends the business rule without external datasource calls ```Usecase``` business rule with ```UsecaseBase<TypeUsecase>``` by typing ```UsecaseBase<TypeUsecase>``` with the desired data ex: ```UsecaseBase<String>```. Where it is typed with the return that will be made by usecase.

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

The "ParametersReturnResult" class. Expects to receive the general parameters necessary for the Usecase call, along with the mandatory parameters ParametersBasic:
```showRuntimeMilliseconds``` responsible for showing the time it took to execute the call in milliseconds;
```nameFeature``` responsible for identifying the feature;
```AppError``` responsible for handling the Error;


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
