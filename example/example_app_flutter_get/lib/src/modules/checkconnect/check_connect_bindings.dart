import 'package:get/get.dart';
import 'ui/check_connect_controller.dart';

class CheckConnectBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CheckConnectController>(
      () => CheckConnectController(
        featuresCheckconnectPresenter: Get.find(),
      ),
    );
  }
}
