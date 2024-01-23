import 'package:flutter_modular/flutter_modular.dart';
import 'package:return_success_or_error/return_success_or_error.dart';

import '../../utils/routes.dart';
import 'feature/calc_fibonacci/domain/calc_fibonacci_usecase.dart';
import 'ui/fibonacci_page.dart';
import 'ui/fibonacci_reducer.dart';

class FibonacciModule extends Module {
  @override
  void binds(Injector i) {
    i.add<UsecaseBase<int>>(
      CalcFibonacciUsecase.new,
    );
    i.addSingleton<FibonacciReducer>(
      FibonacciReducer.new,
      config: BindConfig(
        onDispose: (reducer) => reducer.dispose(),
      ),
    );
  }

  @override
  void routes(r) {
    r.child(
      Routes.initial.caminho,
      child: (context) => const FibonacciPage(),
    );
  }
}
