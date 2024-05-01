import 'package:return_success_or_error/return_success_or_error.dart';

import 'feature/features_service_presenter.dart';
import 'service_binding.dart';

Future<void> startServices() async {
  await Service.to.initDependences(() async => ServiceBinding().initBindings());
  await Service.to.initServices([
    FeaturesServicePresenter.to.widgetsFlutterBinding(),
    FeaturesServicePresenter.to.connectivityUsecase(),
  ]);
}
