import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:return_success_or_error/return_success_or_error.dart';

import 'features/check_connect/datasource/connectivity_datasource.dart';
import 'features/check_connect/domain/usecase/check_connect_usecase.dart';
import 'ui/check_connect_page.dart';
import 'ui/check_connect_reducer.dart';

final checkConnectPresenter = Modular.get<
    UsecaseBaseCallData<String, ({bool conect, String typeConect})>>();

class CheckConnectModule extends Module {
  @override
  void binds(i) {
    i.addSingleton(CheckConnectReducer.new);
    i.addInstance<Connectivity>(Connectivity());
    i.add<Datasource<({bool conect, String typeConect})>>(
      ConnectivityDatasource.new,
    );
    i.add<UsecaseBaseCallData<String, ({bool conect, String typeConect})>>(
        CheckConnectUsecase.new,
        key: 'check_connect');
  }

  @override
  void routes(r) {
    r.child('/', child: (context) => const CheckConnectPage());
  }
}
