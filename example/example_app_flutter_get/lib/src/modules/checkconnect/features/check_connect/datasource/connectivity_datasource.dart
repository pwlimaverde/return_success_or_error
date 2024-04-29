import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:return_success_or_error/return_success_or_error.dart';

import '../domain/model/check_connect_model.dart';

///Datasources
final class ConnectivityDatasource implements Datasource<CheckConnecModel> {
  final Connectivity connectivity;

  ConnectivityDatasource(this.connectivity);

  @override
  Future<CheckConnecModel> call(
    NoParams parameters,
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
      return CheckConnecModel(connect: isOnline, typeConect: type);
    } catch (e) {
      throw parameters.error..message = "$e";
    }
  }
}
