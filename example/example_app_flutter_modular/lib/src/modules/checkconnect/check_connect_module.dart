import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:return_success_or_error/return_success_or_error.dart';

import '../../utils/routes.dart';
import 'features/check_connect/datasource/connectivity_datasource.dart';
import 'features/check_connect/domain/model/check_connect_model.dart';
import 'features/check_connect/domain/usecase/check_connect_usecase.dart';
import 'features/features_checkconnect_presenter.dart';
import 'features/simple_counter/domain/usecase/two_plus_two_usecase.dart';
import 'ui/check_connect_page.dart';
import 'ui/check_connect_reducer.dart';

final class CheckConnectModule extends Module {
  @override
  void binds(i) {
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
    i.addSingleton<CheckConnectReducer>(
      CheckConnectReducer.new,
      config: BindConfig(
        onDispose: (reducer) => reducer.dispose(),
      ),
    );
  }

  @override
  void routes(r) {
    r.child(Routes.initial.caminho,
        child: (context) => const CheckConnectPage());
  }
}
