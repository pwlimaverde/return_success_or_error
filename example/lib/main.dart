import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:return_success_or_error/return_success_or_error.dart';

import 'animation_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
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

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  String? _resultChecarConeccao;
  String? _resultChecarTypeConeccao;

  final checarConeccaoUsecase = ChecarConeccaoUsecase(
    datasource: ConnectivityDatasource(
      connectivity: Connectivity(),
    ),
  );

  void _checkConnection() async {
    final data = await checarConeccaoUsecase(
      NoParams(
        error: ErrorGeneric(
          message: "Conect error",
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
      NoParams(
        error: ErrorGeneric(
          message: "Conect error",
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
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const StaggerDemo()));
              },
              icon: const Icon(Icons.addchart_outlined))
        ],
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

  @override
  Future<({bool conect, String typeConect})> call(
    ParametersReturnResult parameters,
  ) async {
    try {
      bool isOnline = await connectivity.checkConnectivity().then((result) {
        return result == ConnectivityResult.wifi ||
            result == ConnectivityResult.mobile ||
            result == ConnectivityResult.ethernet;
      });

      String type = await connectivity.checkConnectivity().then((result) {
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
      });
      return (conect: isOnline, typeConect: type);
    } catch (e) {
      throw parameters.error..message = "$e";
    }
  }
}

///Usecase with external Datasource call
final class ChecarConeccaoUsecase
    extends UsecaseBaseCallData<String, ({bool conect, String typeConect})> {
  ChecarConeccaoUsecase({required super.datasource});

  @override
  Future<ReturnSuccessOrError<String>> call(NoParams parameters) async {
    final resultDatacource = await resultDatasource(
      parameters: parameters,
      datasource: datasource,
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

///Usecase only with the business rule
final class ChecarTypeConeccaoUsecase extends UsecaseBase<String> {
  final Connectivity connectivity;

  ChecarTypeConeccaoUsecase({required this.connectivity});

  @override
  Future<ReturnSuccessOrError<String>> call(NoParams parameters) async {
    var result = await connectivity.checkConnectivity().then((value) {
      switch (value) {
        case ConnectivityResult.wifi:
          return "Conect wifi";
        case ConnectivityResult.mobile:
          return "Conect mobile";
        case ConnectivityResult.ethernet:
          return "Conect ethernet";
        default:
          return "Conect none";
      }
    });

    if (result == "Conect none") {
      return ErrorReturn(
        error: ErrorGeneric(message: "You are Offline!"),
      );
    } else {
      return SuccessReturn(
        success: result,
      );
    }
  }
}
