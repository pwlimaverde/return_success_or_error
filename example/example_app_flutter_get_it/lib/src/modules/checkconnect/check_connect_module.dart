import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_getit/flutter_getit.dart';

import '../../utils/routes.dart';
import '../../utils/typedefs.dart';
import '../service/feature/service_hub.dart';
import 'features/check_connect/datasource/connectivity_datasource.dart';
import 'features/check_connect/domain/usecase/check_connect_usecase.dart';
import 'features/features_checkconnect_composer.dart';
import 'features/simple_counter/domain/usecase/two_plus_two_usecase.dart';
import 'ui/check_connect_controller.dart';
import 'ui/check_connect_page.dart';

final class CheckConnectModule extends FlutterGetItModule {
  @override
  List<Bind<Object>> get bindings => [
    Bind.lazySingleton<Connectivity>((i) => ServiceHub.to.connectivity),
    Bind.lazySingleton<CCData>((i) => ConnectivityDatasource(i())),
    Bind.lazySingleton<CCUsecase>((i) => CheckConnectUsecase(i())),
    Bind.factory<TwoPlusTowUsecase>((i) => TwoPlusTowUsecase()),
    Bind.lazySingleton<FeaturesCheckconnectComposer>(
      (i) => FeaturesCheckconnectComposer(
        checkConnectUsecase: i(),
        twoPlusTowUsecase: i(),
      ),
    ),
  ];

  @override
  String get moduleRouteName => Routes.checkconnect.caminho;

  @override
  List<FlutterGetItPageRouter> get pages => [
    FlutterGetItPageRouter(
      name: '/',
      builder: (context) => const CheckConnectPage(),
      bindings: [
        Bind.lazySingleton<CheckConnectController>(
          (i) => CheckConnectController(featuresCheckconnectPresenter: i()),
        ),
      ],
    ),
  ];
}
