import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_getit/src/dependency_injector/binds/bind.dart';

import 'package:return_success_or_error/return_success_or_error.dart';

import '../../../utils/bindings.dart';
import 'check_connect/datasource/connectivity_datasource.dart';
import 'check_connect/domain/model/check_connect_model.dart';
import 'check_connect/domain/usecase/check_connect_usecase.dart';
import 'features_checkconnect_presenter.dart';
import 'simple_counter/domain/usecase/two_plus_two_usecase.dart';

final class FeaturesCheckconnectBindings implements Bindings {
  @override
  List<Bind<Object>> bindings = [
    Bind.lazySingleton<Connectivity>(
      (i) => Connectivity(),
    ),
    Bind.factory<Datasource<CheckConnecModel>>(
      (i) => ConnectivityDatasource(
        connectivity: i(),
      ),
    ),
    Bind.factory<UsecaseBaseCallData<String, CheckConnecModel>>(
      (i) => CheckConnectUsecase(
        i(),
      ),
    ),
    Bind.factory<UsecaseBase<int>>(
      (i) => TwoPlusTowUsecase(),
    ),
    Bind.lazySingleton<FeaturesCheckconnectPresenter>(
      (i) => FeaturesCheckconnectPresenter(
        checkConnectUsecase: i(),
        twoPlusTowUsecase: i(),
      ),
    ),
  ];
}
