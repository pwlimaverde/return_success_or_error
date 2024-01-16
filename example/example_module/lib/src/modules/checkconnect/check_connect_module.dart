import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:return_success_or_error/return_success_or_error.dart';

import 'features/check_connect/datasource/connectivity_datasource.dart';
import 'features/check_connect/domain/model/check_connect_model.dart';
import 'features/check_connect/domain/usecase/check_connect_usecase.dart';
import 'features/check_connect/presenter/check_connect_presenter.dart';
import 'ui/check_connect_page.dart';
import 'ui/check_connect_reducer.dart';

class CheckConnectModule extends Module {
  @override
  void binds(i) {
    i.addSingleton<CheckConnectReducer>(CheckConnectReducer.new,
        config: BindConfig(onDispose: (reducer) => reducer.dispose()));
    i.addInstance<Connectivity>(Connectivity());
    i.add<Datasource<CheckConnecModel>>(
      ConnectivityDatasource.new,
    );
    i.add<UsecaseBaseCallData<String, CheckConnecModel>>(
      CheckConnectUsecase.new,
    );
    i.add<PresenterBaseCallData<String, CheckConnecModel>>(
        CheckConnectPresenter.new);
  }

  @override
  void routes(r) {
    r.child('/', child: (context) => const CheckConnectPage());
  }
}
