import 'package:flutter/material.dart';
import 'package:flutter_getit/flutter_getit.dart';

import '../../utils/routes.dart';
import 'features/features_checkconnect_bindings.dart';
import 'ui/check_connect_page_route.dart';

final class CheckConnectModule extends FlutterGetItModule {
  @override
  List<Bind<Object>> get bindings => [
        ...FeaturesCheckconnectBindings().bindings,
      ];

  @override
  String get moduleRouteName => Routes.checkconnect.caminho;

  @override
  Map<String, WidgetBuilder> get pages => {
        '/': (context) => const CheckConnectPageRoute(),
      };
}
