import 'package:rx_notifier/rx_notifier.dart';

import 'check_connect_state.dart';

class CheckConnectReducer extends RxReducer {
  CheckConnectReducer() {
    on(() => [checarConnecaoAction], _checkConnectReducer);
  }

  void _checkConnectReducer() {
    checarConeccaoState.value = 'teste';
  }
}
