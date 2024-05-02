import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_getit/flutter_getit.dart';
import 'package:return_success_or_error/return_success_or_error.dart';

import '../../utils/routes.dart';
import '../service/feature/features_service_presenter.dart';
import 'features/check_connect/datasource/connectivity_datasource.dart';
import 'features/check_connect/domain/model/check_connect_model.dart';
import 'features/check_connect/domain/usecase/check_connect_usecase.dart';
import 'features/features_checkconnect_presenter.dart';
import 'features/simple_counter/domain/usecase/two_plus_two_usecase.dart';
import 'ui/check_connect_controller.dart';
import 'ui/check_connect_page.dart';

final class CheckConnectModule extends FlutterGetItModule {
  @override
  List<Bind<Object>> get bindings => [
        Bind.factory<Datasource<CheckConnecModel>>(
          (i) => ConnectivityDatasource(),
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
        Bind.lazySingleton(
          (i) => CheckConnectController(
            featuresCheckconnectPresenter: i(),
          ),
        ),
      ];

  @override
  String get moduleRouteName => Routes.checkconnect.caminho;

  @override
  Map<String, WidgetBuilder> get pages => {
        '/': (context) => const CheckConnectPage(),
      };
}
