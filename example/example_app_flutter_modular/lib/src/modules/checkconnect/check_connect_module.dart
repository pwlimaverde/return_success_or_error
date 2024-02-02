import 'package:flutter_modular/flutter_modular.dart';

import '../../utils/routes.dart';
import 'features/features_checkconnect_bindings.dart';
import 'ui/check_connect_page.dart';
import 'ui/check_connect_reducer.dart';

class CheckConnectModule extends Module {
  @override
  List<Module> get imports => [
        FeaturesCheckconnectBindings(),
      ];

  @override
  void binds(i) {
    i.addSingleton<CheckConnectReducer>(
      CheckConnectReducer.new,
      config: BindConfig(
        onDispose: (reducer) => reducer.dispose(),
      ),
    );
  }

  @override
  void routes(r) {
    r.child(Routes.initial.caminho,
        child: (context) => const CheckConnectPage());
  }
}
