import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

import '../../utils/module.dart';
import '../../utils/routes.dart';
import 'check_connect_bindings.dart';
import 'ui/check_connect_page.dart';

final class CheckConnectModule implements Module {
  @override
  List<GetPage> routes = [
    GetPage(
      name: Routes.checkconnect.caminho,
      page: () => const CheckConnectPage(),
      bindings: [
        CheckConnectBindings(),
      ],
    )
  ];
}
