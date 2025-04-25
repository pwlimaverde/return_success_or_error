import 'package:get/get.dart';
import 'feature/calc_fibonacci/domain/calc_fibonacci_usecase.dart';
import 'feature/features_fibonacci_presenter.dart';
import 'ui/fibonacci_controller.dart';

final class FibonacciBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CalcFibonacci>(
      () => CalcFibonacciUsecase(),
    );
    Get.lazyPut<FeaturesFibonacciPresenter>(
      () => FeaturesFibonacciPresenter(
        calcFibonacciUsecase: Get.find(),
      ),
    );
    Get.lazyPut<FibonacciController>(
      () => FibonacciController(
        featuresFibonacciComposer: Get.find(),
      ),
    );
  }
}
