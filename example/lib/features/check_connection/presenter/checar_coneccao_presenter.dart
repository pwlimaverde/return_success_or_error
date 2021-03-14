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
    final resultado = await ReturnResultPresenter<bool>(
      showRuntimeMilliseconds: showRuntimeMilliseconds,
      nameFeature: "Checar Conecção",
      datasource: ConnectivityDatasource(
        connectivity: connectivity ?? Connectivity(),
      ),
    ).returnResult(parameters: NoParams(messageError: "Você está offline"));

    return resultado;
  }
}
