import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:return_success_or_error/return_success_or_error.dart';

import '../domain/model/check_connect_model.dart';

///Datasources
final class ConnectivityDatasource implements Datasource<CheckConnecModel> {
  final Connectivity connectivity;

  ConnectivityDatasource(this.connectivity);

  @override
  Future<CheckConnecModel> call(NoParams parameters) async {
    try {
      bool isOnline = await connectivity.checkConnectivity().then((result) {
        return !result.contains(ConnectivityResult.none);
      });

      String type = await connectivity.checkConnectivity().then((result) {
        if (result.contains(ConnectivityResult.mobile)) {
          return "Conect mobile";
        } else if (result.contains(ConnectivityResult.wifi)) {
          return "Conect wifi";
        } else if (result.contains(ConnectivityResult.ethernet)) {
          return "Conect ethernet";
        } else {
          return "Conect none";
        }
      });
      return CheckConnecModel(connect: isOnline, typeConect: type);
    } catch (e) {
      throw parameters.error..message = "$e";
    }
  }
}
