import 'package:flutter_modular/flutter_modular.dart';

import '../../utils/routes.dart';
import 'feature/features_fibonacci_bindings.dart';
import 'ui/fibonacci_page.dart';
import 'ui/fibonacci_reducer.dart';

final class FibonacciModule extends Module {
  @override
  List<Module> get imports => [
        FeaturesFibonacciBindings(),
      ];

  @override
  void binds(Injector i) {
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
