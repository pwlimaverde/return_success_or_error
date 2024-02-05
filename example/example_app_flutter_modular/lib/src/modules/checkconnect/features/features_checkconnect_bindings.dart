import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:return_success_or_error/return_success_or_error.dart';

import 'check_connect/datasource/connectivity_datasource.dart';
import 'check_connect/domain/model/check_connect_model.dart';
import 'check_connect/domain/usecase/check_connect_usecase.dart';
import 'features_checkconnect_presenter.dart';
import 'simple_counter/domain/usecase/two_plus_two_usecase.dart';

final class FeaturesCheckconnectBindings extends Module {
  @override
  void exportedBinds(Injector i) {
    i.addInstance<Connectivity>(Connectivity());
    i.add<Datasource<CheckConnecModel>>(
      ConnectivityDatasource.new,
    );
    i.add<UsecaseBaseCallData<String, CheckConnecModel>>(
      CheckConnectUsecase.new,
    );
    i.add<UsecaseBase<int>>(
      TwoPlusTowUsecase.new,
    );
    i.add<FeaturesCheckconnectPresenter>(
      FeaturesCheckconnectPresenter.new,
    );
  }
}
