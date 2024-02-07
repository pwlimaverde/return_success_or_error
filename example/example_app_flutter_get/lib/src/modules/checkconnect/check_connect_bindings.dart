import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:return_success_or_error/return_success_or_error.dart';
import 'features/check_connect/datasource/connectivity_datasource.dart';
import 'features/check_connect/domain/model/check_connect_model.dart';
import 'features/check_connect/domain/usecase/check_connect_usecase.dart';
import 'features/features_checkconnect_presenter.dart';
import 'features/simple_counter/domain/usecase/two_plus_two_usecase.dart';
import 'ui/check_connect_controller.dart';

final class CheckConnectBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<Connectivity>(
      () => Connectivity(),
    );
    Get.lazyPut<Datasource<CheckConnecModel>>(
      () => ConnectivityDatasource(
        connectivity: Get.find(),
      ),
    );
    Get.lazyPut<UsecaseBaseCallData<String, CheckConnecModel>>(
      () => CheckConnectUsecase(
        Get.find(),
      ),
    );
    Get.lazyPut<UsecaseBase<int>>(
      () => TwoPlusTowUsecase(),
    );
    Get.lazyPut<FeaturesCheckconnectPresenter>(
      () => FeaturesCheckconnectPresenter(
        checkConnectUsecase: Get.find(),
        twoPlusTowUsecase: Get.find(),
      ),
    );
    Get.lazyPut<CheckConnectController>(
      () => CheckConnectController(
        featuresCheckconnectPresenter: Get.find(),
      ),
    );
  }
}
