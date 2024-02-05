import 'package:flutter_modular/flutter_modular.dart';
import 'package:return_success_or_error/return_success_or_error.dart';

import 'calc_fibonacci/domain/calc_fibonacci_usecase.dart';
import 'features_fibonacci_presenter.dart';

final class FeaturesFibonacciBindings extends Module {
  @override
  void exportedBinds(Injector i) {
    i.add<UsecaseBase<int>>(
      CalcFibonacciUsecase.new,
    );
    i.add<FeaturesFibonacciPresenter>(
      FeaturesFibonacciPresenter.new,
    );
  }
}
