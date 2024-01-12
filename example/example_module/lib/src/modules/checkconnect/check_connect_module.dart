import 'package:flutter_modular/flutter_modular.dart';

import 'ui/check_connect_page.dart';

class CheckConnectModule extends Module {
  @override
  void binds(i) {}

  @override
  void routes(r) {
    r.child('/', child: (context) => const CheckConnectPage());
  }
}