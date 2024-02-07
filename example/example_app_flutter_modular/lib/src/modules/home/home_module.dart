import 'package:flutter_modular/flutter_modular.dart';

import '../../utils/routes.dart';
import 'ui/home_page.dart';

final class HomeModule extends Module {
  @override
  void routes(r) {
    r.child(
      Routes.initial.caminho,
      child: (context) => const HomePage(),
    );
  }
}
