import 'package:flutter/material.dart';
import 'package:flutter_getit/flutter_getit.dart';
import 'package:return_success_or_error/return_success_or_error.dart';

import '../../utils/routes.dart';

import 'feature/calc_fibonacci/domain/calc_fibonacci_usecase.dart';
import 'feature/features_fibonacci_presenter.dart';
import 'ui/fibonacci_controller.dart';
import 'ui/fibonacci_page.dart';

final class FibonacciModule extends FlutterGetItModule {
  @override
  List<Bind<Object>> get bindings => [
        Bind.factory<UsecaseBase<int>>(
          (i) => CalcFibonacciUsecase(),
        ),
        Bind.lazySingleton<FeaturesFibonacciPresenter>(
          (i) => FeaturesFibonacciPresenter(
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
              (i) => i<FibonacciController>(),
            ),
          ],
        ),
  ];
}
