import 'package:flutter_modular/flutter_modular.dart';

import 'modules/checkconnect/check_connect_module.dart';
import 'modules/fibonacci/fibonacci_module.dart';
import 'modules/home/home_module.dart';
import 'utils/routes.dart';

class AppModule extends Module {
  @override
  void routes(r) {
    r.module(Routes.initial.caminho, module: HomeModule());
    r.module(Routes.fibonacci.caminho, module: FibonacciModule());
    r.module(Routes.checkconnect.caminho, module: CheckConnectModule());
  }
}
