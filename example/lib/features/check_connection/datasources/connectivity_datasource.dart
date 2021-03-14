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
