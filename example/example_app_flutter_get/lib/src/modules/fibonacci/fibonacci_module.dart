import 'package:get/get.dart';

import '../../utils/module.dart';
import '../../utils/routes.dart';
import 'feature/features_fibonacci_bindings.dart';
import 'fibonacci_bindings.dart';
import 'ui/fibonacci_page.dart';

class FibonacciModule extends Module {
  @override
  List<GetPage> routes = [
    GetPage(
      name: Routes.fibonacci.caminho,
      page: () => const FibonacciPage(),
      bindings: [
        FibonacciBindings(),
        FeaturesFibonacciBindings(),
      ],
    )
  ];
}
