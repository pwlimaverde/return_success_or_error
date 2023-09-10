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
  String? _resultChecarConeccao;
  String? _resultChecarTypeConeccao;

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

  final checarTypeConeccaoUsecase = ChecarTypeConeccaoUsecase(
    connectivity: Connectivity(),
  );

  void _checkTypeConnection() async {
    final data = await checarTypeConeccaoUsecase(
      parameters: NoParams(
        basic: ParametersBasic(
          error: ErrorGeneric(
            message: "Conect error",
          ),
          showRuntimeMilliseconds: true,
          isIsolate: true,
        ),
      ),
    );

    switch (data) {
      case SuccessReturn<String>():
        _resultChecarTypeConeccao = data.result;
        setState(() {});

      case ErrorReturn<String>():
        _resultChecarTypeConeccao = data.result.message;
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
  Future<ReturnSuccessOrError<String>> call(
      {required NoParams parameters}) async {
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
              error: parameters.basic.error..message = "You are offline");
        }
      case ErrorReturn<({bool conect, String typeConect})>():
        return ErrorReturn(
            error: ErrorGeneric(message: "Error check Connectivity"));
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
  Future<ReturnSuccessOrError<String>> call(
      {required NoParams parameters}) async {
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
