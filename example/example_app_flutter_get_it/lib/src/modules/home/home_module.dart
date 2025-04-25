import 'package:flutter_getit/flutter_getit.dart';

import '../../utils/routes.dart';
import 'ui/home_page.dart';

final class HomeModule extends FlutterGetItModule {
  @override
  String get moduleRouteName => Routes.initial.caminho;

  @override
  List<FlutterGetItPageRouter> get pages => [
    FlutterGetItPageRouter(name: '/', builder: (context) => const HomePage()),
  ];
}
