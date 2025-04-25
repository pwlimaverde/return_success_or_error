import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:return_success_or_error/return_success_or_error.dart';

import 'features/connectivity/domain/usecase/connectivity_usecase.dart';
import 'features/features_service_composer.dart';
import 'features/service_hub.dart';
import 'features/widgets_flutter_binding/datasource/widgets_flutter_binding_datasource.dart';
import 'features/widgets_flutter_binding/domain/usecase/widgets_flutter_binding_usecase.dart';

final class ServiceBindings implements Binding {
  @override
  List<Bind> dependencies() => [
    Bind.put<ServiceHub>(ServiceHub()),
    Bind.lazyPut<ConnectUsecase>(
      () => ConnectivityUsecase(),
    ),
    Bind.lazyPut<Datasource<WidgetsBinding>>(
      () => WidgetsFlutterBindingDatasource(),
    ),
    Bind.lazyPut<WidUsecase>(
      () => WidgetsFlutterBindingUsecase(
        Get.find(),
      ),
    ),
    Bind.put<FeaturesServiceComposer>(
      FeaturesServiceComposer(
        serviceHub: Get.find(),
        widgetsFlutterBindingUsecase: Get.find(),
        connectivityUsecase: Get.find(),

      ),
    ),
  ];
}
