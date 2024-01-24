import 'package:get/get.dart';
import 'package:return_success_or_error/return_success_or_error.dart';

import 'feature/calc_fibonacci/domain/calc_fibonacci_usecase.dart';
import 'ui/fibonacci_controller.dart';

class FibonacciBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UsecaseBase<int>>(
      () => CalcFibonacciUsecase(),
    );
    Get.lazyPut<FibonacciController>(
      () => FibonacciController(
        Get.find(),
      ),
    );
  }
}
