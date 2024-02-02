import 'package:get/get.dart';
import 'package:return_success_or_error/return_success_or_error.dart';

import 'calc_fibonacci/domain/calc_fibonacci_usecase.dart';
import 'features_fibonacci_presenter.dart';

class FeaturesFibonacciBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UsecaseBase<int>>(
      () => CalcFibonacciUsecase(),
    );
    Get.lazyPut<FeaturesFibonacciPresenter>(
      () => FeaturesFibonacciPresenter(
        calcFibonacciUsecase: Get.find(),
      ),
    );
  }
}
