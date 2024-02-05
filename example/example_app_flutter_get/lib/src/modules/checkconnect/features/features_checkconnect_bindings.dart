import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:return_success_or_error/return_success_or_error.dart';

import 'check_connect/datasource/connectivity_datasource.dart';
import 'check_connect/domain/model/check_connect_model.dart';
import 'check_connect/domain/usecase/check_connect_usecase.dart';
import 'features_checkconnect_presenter.dart';
import 'simple_counter/domain/usecase/two_plus_two_usecase.dart';

final class FeaturesCheckconnectBindings implements Bindings {
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
  }
}
