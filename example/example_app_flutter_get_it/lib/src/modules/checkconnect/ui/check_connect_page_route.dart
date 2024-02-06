import 'package:flutter/material.dart';
import 'package:flutter_getit/flutter_getit.dart';

import 'check_connect_controller.dart';
import 'check_connect_page.dart';

class CheckConnectPageRoute extends FlutterGetItModulePageRouter {
  const CheckConnectPageRoute({super.key});

  @override
  List<Bind<Object>> get bindings => [
        Bind.lazySingleton(
          (i) => CheckConnectController(
            featuresCheckconnectPresenter: i(),
          ),
        ),
      ];

  @override
  WidgetBuilder get view => (context) => const CheckConnectPage();
}
