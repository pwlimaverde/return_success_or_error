import 'package:flutter_getit/flutter_getit.dart';

import 'modules/checkconnect/check_connect_module.dart';
import 'modules/home/home_module.dart';
import 'utils/module.dart';

final class AppModule implements Module {
  @override
  List<FlutterGetItModule> routes = [
    HomeModule(),
    CheckConnectModule(),
  ];
}
