import 'package:return_success_or_error/return_success_or_error.dart';

import 'feature/features_service_presenter.dart';
import 'service_bindings.dart';

Future<void> initServices() async {
  ServiceBindings().dependencies();
  await Future.wait([
    FeaturesServicePresenter.to.widgetsFlutterBinding(
      NoParams(),
    ),
  ]);
}
