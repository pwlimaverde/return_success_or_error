import 'package:return_success_or_error/return_success_or_error.dart';

import 'features/features_service_composer.dart';
import 'service_bindings.dart';

Future<void> startServices() async {
  await Service.to
      .initDependences(() async => ServiceBindings().dependencies());
  await Service.to.initServices([
    FeaturesServiceComposer.to.widgetsFlutterBinding(),
    FeaturesServiceComposer.to.connectivityUsecase(),
  ]);
}
