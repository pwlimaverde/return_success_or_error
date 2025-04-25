import 'package:flutter_getit/flutter_getit.dart';

import '../../utils/routes.dart';

import '../../utils/typedefs.dart';
import 'feature/calc_fibonacci/domain/calc_fibonacci_usecase.dart';
import 'feature/features_fibonacci_composer.dart';
import 'ui/fibonacci_controller.dart';
import 'ui/fibonacci_page.dart';

final class FibonacciModule extends FlutterGetItModule {
  @override
  List<Bind<Object>> get bindings => [
        Bind.lazySingleton<FBUsecase>(
          (i) => CalcFibonacciUsecase(),
        ),
        Bind.lazySingleton<FeaturesFibonacciComposer>(
          (i) => FeaturesFibonacciComposer(
            calcFibonacciUsecase: i(),
          ),
        ),
      ];

  @override
  String get moduleRouteName => Routes.fibonacci.caminho;

  @override
  List<FlutterGetItPageRouter> get pages => [
        FlutterGetItPageRouter(
          name: '/',
          builder: (context) => const FibonacciPage(),
          bindings: [
            Bind.lazySingleton<FibonacciController>(
              (i) => FibonacciController(featuresFibonacciComposer: i()),
            ),
          ],
        ),
  ];
}
