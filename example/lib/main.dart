import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:return_success_or_error/return_success_or_error.dart';

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

///Datasources
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

///Usecases
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
