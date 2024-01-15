import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:return_success_or_error/return_success_or_error.dart';

///Datasources
final class ConnectivityDatasource
    implements Datasource<({bool conect, String typeConect})> {
  final Connectivity connectivity;
  ConnectivityDatasource({required this.connectivity});

  @override
  Future<({bool conect, String typeConect})> call(
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
      return (conect: isOnline, typeConect: type);
    } catch (e) {
      throw parameters.error..message = "$e";
    }
  }
}
