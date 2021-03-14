# return_success_or_error

[Read this page in English](https://github.com/pwlimaverde/return_success_or_error/blob/master/README.md)

[Leia esta página em português](https://github.com/pwlimaverde/return_success_or_error/blob/master/README-pt.md)

Abstração de Usecase retornando sucesso ou erro de uma chamada feita pelo datasource

----
Package criado com intuito de abstrair e simplificar os casos de uso, repositorios, datasouces e parametros, difundidos pelo tio Bob. Onde o resultado do datasource é retornado e os erros tratados de forma simples.

Exemplo de chamada à partir de um banco de dados:

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


O tipo do dado esperado é passado na função ```ReturnResultPresenter<Tipo>```. Os parametros esperados são:
```showRuntimeMilliseconds``` responsável por mostar o tempo que levou para executar a chamada em milesegundos;
```nameFeature``` responsável pela identificação da feature;
```datasource``` responsável pela chamada externa, onde e retornado o resultado esperado ou o erro;
Apos a construção da função, é chamado o ```.returnResult``` onde os parametros necessários para o datasouce são passados.

O resultado da função ```ReturnResultPresenter<Tipo>``` é um: ```ReturnSuccessOrError<Tipo>``` que armazena os 2 resultados possíveis:
```SuccessReturn<Tipo>``` que por sua vez armazena o sucesso da chamada;
```ErrorReturn<Tipo>``` que por sua vez armazena o erro da chamada;

Exemplo de recuperação da informação contida no ```ReturnSuccessOrError<Tipo>```:

```
final result = await value.fold(
      success: (value) => value.result,
      error: (value) => value.error,
    )
```

A partir do ```ReturnSuccessOrError<Tipo>``` poderar ser verificado se o retorno foi sucesso ou erro, apenas verificando:
```is SuccessReturn<Tipo>```;
```is ErrorReturn<Tipo>```;

Exemplo de verificação:

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

Exemplo de implementação de uma feature:
Chegar conexção - Checa se o dispositivo está conectado a internet e retorna um bool:

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
A classe responsavel pela consulta, nesse caso ```ConnectivityDatasource```, precisa implementar a abstração do datasource ```Datasource<Tipo, ParametersReturnResult>```, que por sua vez precisa declarar o ```Tipo``` do dado a ser retornado e os ```ParametersReturnResult``` para chegar ao resultado. ex: ```Datasource<bool, NoParams>``` ou ```Datasource<bool, ParametersEmail>```. A classe ```ParametersReturnResult``` é uma abstração para carregar os parameters necesssários para fazer a chamada externa, ex:

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

Ao implementar a classe ```ParametrosRetornoResultado```, precisa sorescrever o ```get mensagemErro```, que é o responsável por identificar a menssagem que será apresentada em caso de erro. Nessa classe é armazenado os dados que serão consultados.

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
  bool? _result;

  void _checkConnection() async {
    _value = await ChecarConeccaoPresenter(
      showRuntimeMilliseconds: true,
    ).consultaConectividade();

    _result = _value!.fold(
      success: (value) => value.result,
      error: (value) => value.error,
    );
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
              'Connection query value:',
            ),
            Text(
              '$_value',
              style: Theme.of(context).textTheme.headline6,
            ),
            Text(
              'Connection query result:',
            ),
            Text(
              '$_result',
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