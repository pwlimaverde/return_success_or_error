# return_success_or_error

Usecase abstraction returning success or error from a call made by the data source

Package criado com intuito de abstrair e simplificar os casos de uso, repositorios, datasouces e parametros, difundidos pelo tio Bob. Onde o resultado do datasource é retornado e os erros tratados de forma simples.

Exemplo de chamada à partir de um banco de dados:

´´´
final value = await ReturnResultPresenter<Stream<User>>(
      mostrarTempoExecucao: true,
      nomeFeature: "Carregar User",
      datasource: datasource,
    ).returnResult(
        parametros:
            NoParams(mensagemErro: "Erro ao carregar os dados do User"));
    return value;
´´´

O tipo do dado esperado é passado na função ReturnResultPresenter<Tipo>. Os parametros esperados são:
"showRuntimeMilliseconds" responsável por mostar o tempo que levou para executar a chamada em milesegundos;
"nameFeature" responsável pela identificação da feature;
"datasource" responsável pela chamada externa, onde e retornado o resultado esperado ou o erro;
Apos a construção da função, é chamado o ".returnResult" onde os parametros necessários para o datasouce é passado.

Exemplo de implementação de uma feature:
Chegar conexção - Checa se o dispositivo está conectado a internet e retorna um bool:

hierarquia:
lib:
    features:
        check_connection:
            datasouces:
                connectivity_datasource.dart
            presenter:
                checar_coneccao_presenter.dart
    main.dart

----
datasouces:
    connectivity_datasource.dart

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
        throw ErroReturnResult(message: "${parameters.messageError}");
      }
      return result;
    } catch (e) {
      throw ErroReturnResult(message: "${parameters.messageError}");
    }
  }
}
----
A classe responsavel pela consulta, nesse caso "ConnectivityDatasource", precisa implementar a abstração do datasource "Datasource<Tipo, ParametersReturnResult>", que por sua vez precisa declarar o Tipo do dado a ser retornado e os ParametersReturnResult para chegar ao resultado. ex: Datasource<bool, NoParams> ou Datasource<bool, ParametersEmail>. A classe ParametersReturnResult é uma abstração para carregar os parameters necesssários para fazer a chamada externa, ex:

____

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
____

Ao implementar a classe ParametrosRetornoResultado, precisa sorescrever o get mensagemErro, que é o responsável por identificar a menssagem que será apresentada em caso de erro. Nessa classe é armazenado os dados que serão consultados.

----
presenter:
    checar_coneccao_presenter.dart
    
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
----

----
main.dart
    
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
----

