import 'package:get/get.dart';
import 'package:return_success_or_error/return_success_or_error.dart';

import '../features/check_connect/domain/model/check_connect_model.dart';

class CheckConnectController extends GetxController {
  final UsecaseBaseCallData<String, CheckConnecModel> usecase;
  CheckConnectController(this.usecase);

  final _checarConeccaoState = RxnString(null);
  set checarConeccaoState(value) => _checarConeccaoState.value = value;
  get checarConeccaoState => _checarConeccaoState.value;

  void checkConnect() async {
    final status = await usecase(NoParams());
    switch (status) {
      case SuccessReturn<String>():
        _checarConeccaoState(status.result);
      case ErrorReturn<String>():
        _checarConeccaoState(status.result.message);
    }
  }
}
