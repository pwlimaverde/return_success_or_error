import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:return_success_or_error/return_success_or_error.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
  late ({AppError? error, bool? result}) _value;
  bool? _result;
  final checarConeccaoUsecase = ChecarConeccaoUsecase(
    datasource: ConnectivityDatasource(
      connectivity: Connectivity(),
    ),
  );

  void _checkConnection() async {
    _value = await checarConeccaoUsecase(
      parameters: NoParams(
        basic: ParametersBasic(
          error: ErrorReturnResult(
            message: "Erro de conexão",
          ),
          nameFeature: "Checar Conecção",
          showRuntimeMilliseconds: true,
          isIsolate: true,
        ),
      ),
    );

    if (_value.result != null) {
      _result = _value.result;
      setState(() {});
    } else {
      _result = false;
      setState(() {});
    }
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
    print(result);
    return result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet;
  }

  @override
  Future<bool> call({required ParametersReturnResult parameters}) async {
    try {
      final result = await isOnline;
      return result;
    } catch (e) {
      throw parameters.basic.error..message = "$e";
    }
  }
}

///Usecases
final class ChecarConeccaoUsecase extends UsecaseBase<bool, bool> {
  ChecarConeccaoUsecase({required super.datasource});

  @override
  Future<({AppError? error, bool? result})> call(
      {required ParametersReturnResult parameters}) async {
    final resultDatacource =
        await returResult(parameters: parameters, datasource: super.datasource);

    if (resultDatacource.result != null) {
      if (resultDatacource.result!) {
        return resultDatacource;
      } else {
        return (
          result: false,
          error: parameters.basic.error..message = "Você está offline",
        );
      }
    } else {
      return (
        result: null,
        error: ErrorReturnResult(message: "Error check Connectivity"),
      );
    }
  }
}
