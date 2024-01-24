import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:return_success_or_error/return_success_or_error.dart';

import 'features/check_connect/datasource/connectivity_datasource.dart';
import 'features/check_connect/domain/model/check_connect_model.dart';
import 'features/check_connect/domain/usecase/check_connect_usecase.dart';
import 'ui/check_connect_controller.dart';

class CheckConnectBindings implements Bindings {
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
    Get.lazyPut<CheckConnectController>(
      () => CheckConnectController(
        Get.find(),
      ),
    );
  }
}
