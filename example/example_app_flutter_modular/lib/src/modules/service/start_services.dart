import 'package:return_success_or_error/return_success_or_error.dart';

import 'features/features_service_composer.dart';
import 'service_binding.dart';

Future<void> startServices() async {
  await Service.to.initDependences(() async => ServiceBinding().initBindings());
  await Service.to.initServices([
    FeaturesServiceComposer.to.widgetsFlutterBinding(),
    FeaturesServiceComposer.to.connectivityUsecase(),
  ]);
}
