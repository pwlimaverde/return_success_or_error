import 'package:get/get.dart';

import '../../utils/module.dart';
import '../../utils/routes.dart';
import 'ui/home_page.dart';

final class HomeModule implements ModuleSystem {
  @override
  List<GetPage> routes = [
    GetPage(
      name: Routes.initial.caminho,
      page: () => const HomePage(),
      transitionDuration: const Duration(milliseconds: 0),
      transition: Transition.fadeIn,
      reverseTransitionDuration: const Duration(milliseconds: 0),
    )
  ];
}
