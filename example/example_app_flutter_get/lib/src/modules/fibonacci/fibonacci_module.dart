import 'package:get/get.dart';

import '../../utils/module.dart';
import '../../utils/routes.dart';
import 'fibonacci_bindings.dart';
import 'ui/fibonacci_page.dart';

final class FibonacciModule implements ModuleSystem {
  @override
  List<GetPage> routes = [
    GetPage(
      name: Routes.fibonacci.caminho,
      page: () => const FibonacciPage(),
      transitionDuration: const Duration(milliseconds: 0),
      transition: Transition.fadeIn,
      reverseTransitionDuration: const Duration(milliseconds: 0),
      binding: FibonacciBindings(),
    ),
  ];
}
