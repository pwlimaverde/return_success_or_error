import 'package:get/get_navigation/src/routes/get_route.dart';

import 'modules/checkconnect/check_connect_module.dart';
import 'modules/fibonacci/fibonacci_module.dart';
import 'modules/home/home_module.dart';
import 'utils/module.dart';

class AppModule extends Module {
  @override
  List<GetPage> routes = [
    ...HomeModule().routes,
    ...FibonacciModule().routes,
    ...CheckConnectModule().routes,
  ];
}
