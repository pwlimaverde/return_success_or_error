import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:return_success_or_error/return_success_or_error.dart';

import 'check_connect/datasource/connectivity_datasource.dart';
import 'check_connect/domain/usecase/check_connect_usecase.dart';

class FeatureBindings extends Module {
  @override
  void binds(i) {
    i.addInstance<Connectivity>(Connectivity());
    i.add<Datasource<({bool conect, String typeConect})>>(
      ConnectivityDatasource.new,
    );
    i.add<UsecaseBaseCallData<String, ({bool conect, String typeConect})>>(
        CheckConnectUsecase.new,
        key: 'check_connect');
  }
}
