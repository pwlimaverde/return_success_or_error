import 'package:flutter_modular/flutter_modular.dart';

import 'modules/checkconnect/check_connect_module.dart';
import 'modules/fibonacci/fibonacci_module.dart';
import 'modules/home/home_module.dart';

class AppModule extends Module {
  @override
  void binds(i) {}

  @override
  void routes(r) {
    r.module('/', module: HomeModule());
    r.module('/fibonacci', module: FibonacciModule());
    r.module('/checkconnect', module: CheckConnectModule());
  }
}