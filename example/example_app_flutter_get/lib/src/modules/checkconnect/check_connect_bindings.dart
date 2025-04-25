import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:return_success_or_error/return_success_or_error.dart';
import '../service/features/service_hub.dart';
import 'features/check_connect/datasource/connectivity_datasource.dart';
import 'features/check_connect/domain/model/check_connect_model.dart';
import 'features/check_connect/domain/usecase/check_connect_usecase.dart';
import 'features/features_checkconnect_composer.dart';
import 'features/simple_counter/domain/usecase/two_plus_two_usecase.dart';
import 'ui/check_connect_controller.dart';

final class CheckConnectBindings implements Binding {
  @override
  List<Bind> dependencies() => [
    Bind.lazyPut<Connectivity>(
      () => ServiceHub.to.connectivity,
    ),
    Bind.lazyPut<Datasource<CheckConnectModel>>(
      () => ConnectivityDatasource(
        Get.find(),
      ),
    ),
    Bind.lazyPut<CheckConnect>(
      () => CheckConnectUsecase(
        Get.find(),
      ),
    ),
    Bind.lazyPut<TwoPlusTow>(
      () => TwoPlusTowUsecase(),
    ),
    Bind.lazyPut<FeaturesCheckconnectComposer>(
      () => FeaturesCheckconnectComposer(
        checkConnectUsecase: Get.find(),
        twoPlusTowUsecase: Get.find(),
      ),
    ),
    Bind.lazyPut<CheckConnectController>(
      () => CheckConnectController(
        featuresCheckconnectComposer: Get.find(),
      ),
    ),
  ];
}
