import 'package:return_success_or_error/return_success_or_error.dart';

import 'feature/features_service_composer.dart';
import 'service_bindings.dart';

Future<void> startServices() async {
  await Service.to
      .initDependences(() async => ServiceBindings().initBindings());
  await Service.to.initServices([
    FeaturesServicePresenter.to.widgetsFlutterBinding(),
    FeaturesServicePresenter.to.connectivityUsecase(),
  ]);
}
