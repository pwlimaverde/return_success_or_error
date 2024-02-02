import 'package:get/get.dart';

import 'package:return_success_or_error/return_success_or_error.dart';
import '../features/features_checkconnect_presenter.dart';

class CheckConnectController extends GetxController {
  CheckConnectController();

  final _checarConeccaoState = RxnString(null);
  set checarConeccaoState(value) => _checarConeccaoState.value = value;
  String? get checarConeccaoState => _checarConeccaoState.value;

  final _twoPlusTowState = RxnInt(null);
  set twoPlusTowState(value) => _twoPlusTowState.value = value;
  int? get twoPlusTowState => _twoPlusTowState.value;

  void checkConnect() async {
    final status = await Get.find<FeaturesCheckconnectPresenter>().checkConnect(
      NoParams(),
    );
    _checarConeccaoState(status);
  }

  void twoPlusTow() async {
    final status = await Get.find<FeaturesCheckconnectPresenter>().twoPlusTow(
      NoParams(),
    );
    _twoPlusTowState(status);
  }
}
