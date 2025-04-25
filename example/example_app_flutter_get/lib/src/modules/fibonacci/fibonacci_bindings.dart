import 'package:get/get.dart';
import 'feature/calc_fibonacci/domain/calc_fibonacci_usecase.dart';
import 'feature/features_fibonacci_composer.dart';
import 'ui/fibonacci_controller.dart';

final class FibonacciBindings implements Binding {
  @override
  List<Bind> dependencies() => [
        Bind.lazyPut<CalcFibonacci>(
          () => CalcFibonacciUsecase(),
        ),
        Bind.lazyPut<FeaturesFibonacciComposer>(
          () => FeaturesFibonacciComposer(
            calcFibonacciUsecase: Get.find(),
          ),
        ),
        Bind.lazyPut<FibonacciController>(
          () => FibonacciController(
            featuresFibonacciComposer: Get.find(),
          ),
        ),
      ];
}
