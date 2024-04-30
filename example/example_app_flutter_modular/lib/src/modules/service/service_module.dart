import 'package:auto_injector/auto_injector.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:return_success_or_error/return_success_or_error.dart';
import 'feature/connectivity/domain/usecase/connectivity_usecase.dart';
import 'feature/features_service_presenter.dart';
import 'feature/widgets_flutter_binding/datasource/widgets_flutter_binding_datasource.dart';
import 'feature/widgets_flutter_binding/domain/usecase/widgets_flutter_binding_usecase.dart';

// final class ServiceModule extends Module {
//   @override
//   void exportedBinds(i) {
//     i.addInstance<FeaturesServicePresenter>(FeaturesServicePresenter(
//         connectivityUsecase: i.get<ConnectUsecase>(),
//         widgetsFlutterBindingUsecase: i.get<WidUsecase>()));
//   }

//   @override
//   void binds(Injector i) {
//     i.addInstance<Connectivity>(Connectivity());
//     i.add<ConnectUsecase>(ConnectivityUsecase.new);
//     i.add<Datasource<WidgetsBinding>>(WidgetsFlutterBindingDatasource.new);
//     i.add<WidUsecase>(WidgetsFlutterBindingUsecase.new);
//   }
// }

final autoInjector = AutoInjector();

final class ServiceBinding {
  void initBindings() {
    // product_module.dart
    final bindings = AutoInjector(
      tag: 'bindings',
      on: (i) {
        i.addInstance<Connectivity>(Connectivity());

        i.add<ConnectUsecase>(ConnectivityUsecase.new);
        i.add<Datasource<WidgetsBinding>>(WidgetsFlutterBindingDatasource.new);
        i.add<WidUsecase>(WidgetsFlutterBindingUsecase.new);
        i.commit();
      },
    );

// user_module.dart

    autoInjector.addInstance<FeaturesServicePresenter>(FeaturesServicePresenter(
        connectivityUsecase: bindings.get<ConnectUsecase>(),
        widgetsFlutterBindingUsecase: bindings.get<WidUsecase>()));
    autoInjector.commit();
  }
}
