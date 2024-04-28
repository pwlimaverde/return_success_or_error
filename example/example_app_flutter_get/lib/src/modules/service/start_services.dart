import 'package:example_app_flutter_get/src/modules/service/service.dart';
import 'package:return_success_or_error/return_success_or_error.dart';

import 'feature/features_service_presenter.dart';
import 'service_bindings.dart';

Future<void> startServices() async {
  await Service.to
      .initDependences(() async => ServiceBindings().dependencies());
  await Service.to.initServices([
    FeaturesServicePresenter.to.widgetsFlutterBinding(
      NoParams(),
    ),
    FeaturesServicePresenter.to.connectivityUsecase(
      NoParams(),
    ),
  ]);
}
