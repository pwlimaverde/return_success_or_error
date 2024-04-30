import 'package:flutter_modular/flutter_modular.dart';
import '../../utils/routes.dart';
import 'feature/calc_fibonacci/domain/calc_fibonacci_usecase.dart';
import 'feature/features_fibonacci_presenter.dart';
import 'ui/fibonacci_page.dart';
import 'ui/fibonacci_reducer.dart';

final class FibonacciModule extends Module {
  @override
  void binds(Injector i) {
    i.add<CalcFibonacci>(
      CalcFibonacciUsecase.new,
    );
    i.add<FeaturesFibonacciPresenter>(
      FeaturesFibonacciPresenter.new,
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
