import 'package:get/get.dart';

import 'package:return_success_or_error/return_success_or_error.dart';
import '../features/features_checkconnect_composer.dart';

final class CheckConnectController extends GetxController {
  final FeaturesCheckconnectComposer featuresCheckconnectComposer;

  CheckConnectController({
    required this.featuresCheckconnectComposer,
  });

  final _checarConeccaoState = RxnString(null);
  set checarConeccaoState(value) => _checarConeccaoState.value = value;
  String? get checarConeccaoState => _checarConeccaoState.value;

  final _twoPlusTowState = RxnInt(null);
  set twoPlusTowState(value) => _twoPlusTowState.value = value;
  int? get twoPlusTowState => _twoPlusTowState.value;

  void checkConnect() async {
    final status = await featuresCheckconnectComposer.checkConnect(
      NoParams(),
    );
    _checarConeccaoState(status);
  }

  void twoPlusTow() async {
    final status = await featuresCheckconnectComposer.twoPlusTow(
      NoParams(),
    );
    _twoPlusTowState(status);
  }
}
