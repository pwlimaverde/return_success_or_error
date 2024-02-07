import 'package:get/get_navigation/src/routes/get_route.dart';

import '../../utils/module.dart';
import '../../utils/routes.dart';
import 'ui/home_page.dart';

final class HomeModule implements Module {
  @override
  List<GetPage> routes = [
    GetPage(
      name: Routes.initial.caminho,
      page: () => const HomePage(),
    )
  ];
}
