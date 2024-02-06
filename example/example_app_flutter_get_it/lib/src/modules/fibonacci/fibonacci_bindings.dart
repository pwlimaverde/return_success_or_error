import 'package:get/get.dart';
import 'ui/fibonacci_controller.dart';

final class FibonacciBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FibonacciController>(
      () => FibonacciController(
        featuresFibonacciPresenter: Get.find(),
      ),
    );
  }
}
