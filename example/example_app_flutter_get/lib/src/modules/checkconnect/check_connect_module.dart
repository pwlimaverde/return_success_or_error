import 'package:get/get.dart';

import '../../utils/module.dart';
import '../../utils/routes.dart';
import 'check_connect_bindings.dart';
import 'ui/check_connect_page.dart';

final class CheckConnectModule implements ModuleSystem {
  @override
  List<GetPage> routes = [
    GetPage(
      name: Routes.checkconnect.caminho,
      page: () => const CheckConnectPage(),
      transitionDuration: const Duration(milliseconds: 0),
      transition: Transition.fadeIn,
      reverseTransitionDuration: const Duration(milliseconds: 0),
      binding: CheckConnectBindings(),
    ),
  ];
}
