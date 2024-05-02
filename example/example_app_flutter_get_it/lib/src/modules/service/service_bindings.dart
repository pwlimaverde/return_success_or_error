import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:return_success_or_error/return_success_or_error.dart';

import 'feature/connectivity/domain/usecase/connectivity_usecase.dart';
import 'feature/features_service_presenter.dart';
import 'feature/widgets_flutter_binding/datasource/widgets_flutter_binding_datasource.dart';
import 'feature/widgets_flutter_binding/domain/usecase/widgets_flutter_binding_usecase.dart';

final class ServiceBindings {
  void initBindings() {
    final getIt = GetIt.I;
    getIt.registerLazySingleton<Connectivity>(() => Connectivity());
    getIt.registerFactory<ConnectUsecase>(
      () => ConnectivityUsecase(
        connectivity: getIt.get<Connectivity>(),
      ),
    );
    getIt.registerFactory<Datasource<WidgetsBinding>>(
      () => WidgetsFlutterBindingDatasource(),
    );
    getIt.registerFactory<WidUsecase>(
      () => WidgetsFlutterBindingUsecase(
        getIt.get<Datasource<WidgetsBinding>>(),
      ),
    );
    getIt.registerSingleton<FeaturesServicePresenter>(
      FeaturesServicePresenter(
        widgetsFlutterBindingUsecase: getIt.get<WidUsecase>(),
        connectivityUsecase: getIt.get<ConnectUsecase>(),
      ),
    );
  }
}
