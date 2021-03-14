# return_success_or_error

[Read this page in English](https://github.com/pwlimaverde/return_success_or_error/blob/master/README.md)

[Leia esta página em português](https://github.com/pwlimaverde/return_success_or_error/blob/master/README-pt.md)

Usecase abstraction returning success or error from a call made by the data source

----

Package created in order to abstract and simplify the use cases, repositories, datasouces and parameters, disseminated by Uncle Bob. Where the result of the datasource is returned and errors are handled in a simple way.

Example of a call from a database:

```
final value = await ReturnResultPresenter<Stream<User>>(
      showRuntimeMilliseconds: true,
      nameFeature: "Carregar User",
      datasource: datasource,
    ).returnResult(
        parameters:
            NoParams(messageError: "Erro ao carregar os dados do User"));
    return value;
```

The expected data type is passed in the function ```ReturnResultPresenter<Tipo>```. The expected parameters are:
```showRuntimeMilliseconds``` responsible for showing the time it took to execute the call in mileseconds;
```nameFeature``` responsible for identifying the feature;
```datasource``` responsible for the external call, where the expected result or error is returned;
After building the function, it is called the ```.returnResult``` where the necessary parameters for the datasouce are passed.

Example of implementing a feature:
Get connection - Check if the device is connected to the internet and returns a bool:

```
hierarquia:
lib:
    features:
        check_connection:
            datasouces:
                connectivity_datasource.dart
            presenter:
                checar_coneccao_presenter.dart
    main.dart
```
----
datasouces:
    connectivity_datasource.dart

```
import 'package:connectivity/connectivity.dart';
import 'package:return_success_or_error/return_success_or_error.dart';

class ConnectivityDatasource implements Datasource<bool, NoParams> {
  final Connectivity connectivity;
  ConnectivityDatasource({required this.connectivity});

  Future<bool> get isOnline async {
    var result = await connectivity.checkConnectivity();
    return result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile;
  }

  @override
  Future<bool> call({required NoParams parameters}) async {
    try {
      final result = await isOnline;
      if (!result) {
        throw ErrorReturnResult(message: "${parameters.messageError}");
      }
      return result;
    } catch (e) {
      throw ErrorReturnResult(message: "${parameters.messageError}");
    }
  }
}
```
----
The class responsible for the query, in this case ```ConnectivityDatasource```, need to implement the datasource abstraction ```Datasource<Tipo, ParametersReturnResult>```, which in turn needs to declare the ```Tipo``` of the data to be returned and the ```ParametersReturnResult``` to get to the result.
ex: ```Datasource<bool, NoParams>``` or ```Datasource<bool, ParametersEmail>```. The class ```ParametersReturnResult``` is an abstraction to load the necessary parameters to make the external call, ex:

____
```
class ParametrosSalvarHeader implements ParametrosRetornoResultado {
  final String doc;
  final String nome;
  final int prioridade;
  final Map<String, int> corHeader;
  final String user;

  ParametrosSalvarHeader({
    required this.doc,
    required this.nome,
    required this.prioridade,
    required this.corHeader,
    required this.user,
  });

  @override
  String get mensagemErro => "Erro ao atualizar os dados da seção";
}
```
____

When implementing the class ```ParametrosRetornoResultado```, need to write the ```get mensagemErro```, who is responsible for identifying the message that will be displayed in case of error. In this class, the data to be consulted is stored.

----
presenter:
    checar_coneccao_presenter.dart

```    
import 'package:connectivity/connectivity.dart';
import 'package:example/features/datasources/connectivity_datasource.dart';
import 'package:return_success_or_error/return_success_or_error.dart';

class ChecarConeccaoPresenter {
  final Connectivity? connectivity;
  final bool showRuntimeMilliseconds;

  ChecarConeccaoPresenter({
    this.connectivity,
    required this.showRuntimeMilliseconds,
  });

  Future<ReturnSuccessOrError<bool>> consultaConectividade() async {
    final value = await ReturnResultPresenter<bool>(
      showRuntimeMilliseconds: showRuntimeMilliseconds,
      nameFeature: "Checar Conecção",
      datasource: ConnectivityDatasource(
        connectivity: connectivity ?? Connectivity(),
      ),
    ).returnResult(parameters: NoParams(messageError: "Você está offline"));

    return value;
  }
}
```
----

----
main.dart

```    
import 'package:flutter/material.dart';
import 'package:return_success_or_error/return_success_or_error.dart';

import 'features/check_connection/presenter/checar_coneccao_presenter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Check Connection'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ReturnSuccessOrError<bool>? _value;

  void _checkConnection() async {
    _value = await ChecarConeccaoPresenter(
      showRuntimeMilliseconds: true,
    ).consultaConectividade();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Connection query result:',
            ),
            Text(
              '$_value',
              style: Theme.of(context).textTheme.headline6,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _checkConnection,
        tooltip: 'check',
        child: Icon(Icons.cached),
      ),
    );
  }
}
```
----