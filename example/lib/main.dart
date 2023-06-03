import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:return_success_or_error/return_success_or_error.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Check Connection'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ({AppError? error, String? result}) _valueChecarConeccao =
      (error: null, result: null);
  String? _resultChecarConeccao;

  ({AppError? error, String? result}) _valueChecarTypeConeccao =
      (error: null, result: null);
  String? _resultChecarTypeConeccao;

  final checarConeccaoUsecase = ChecarConeccaoUsecase(
    datasource: ConnectivityDatasource(
      connectivity: Connectivity(),
    ),
  );

  void _checkConnection() async {
    _valueChecarConeccao = await checarConeccaoUsecase(
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

    if (_valueChecarConeccao.result != null) {
      _resultChecarConeccao = _valueChecarConeccao.result;
      setState(() {});
    } else {
      _resultChecarConeccao = _valueChecarConeccao.error?.message;
      setState(() {});
    }
  }

  final checarTypeConeccaoUsecase = ChecarTypeConeccaoUsecase(
    connectivity: Connectivity(),
  );

  void _checkTypeConnection() async {
    _valueChecarTypeConeccao = await checarTypeConeccaoUsecase(
      parameters: NoParams(
        basic: ParametersBasic(
          error: ErrorGeneric(
            message: "Conect error",
          ),
          nameFeature: "Check Type Conect",
          showRuntimeMilliseconds: true,
          isIsolate: true,
        ),
      ),
    );

    if (_valueChecarTypeConeccao.result != null) {
      _resultChecarTypeConeccao = _valueChecarTypeConeccao.result;
      setState(() {});
    } else {
      _resultChecarTypeConeccao = _valueChecarTypeConeccao.error?.message;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Connection query result:',
            ),
            Text(
              _resultChecarConeccao ?? "Check conect",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const Text(
              'Connection type result:',
            ),
            Text(
              _resultChecarTypeConeccao ?? "Check conect",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _checkConnection();
          _checkTypeConnection();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.analytics),
      ),
    );
  }
}

///Datasources
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

///Usecase with external Datasource call
final class ChecarConeccaoUsecase
    extends UsecaseBaseCallData<String, ({bool conect, String typeConect})> {
  ChecarConeccaoUsecase({required super.datasource});

  @override
  Future<({AppError? error, String? result})> call(
      {required ParametersReturnResult parameters}) async {
    final resultDatacource = await resultDatasource(
        parameters: parameters, datasource: super.datasource);

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

///Usecase only with the business rule
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
  Future<({AppError? error, String? result})> call(
      {required ParametersReturnResult parameters}) async {
    if (await type == "Conect none") {
      return (
        result: null,
        error: ErrorGeneric(message: "You are Offline!"),
      );
    } else {
      return (
        result: await type,
        error: null,
      );
    }
  }
}
