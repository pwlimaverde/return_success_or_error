import 'package:return_success_or_error/return_success_or_error.dart';
import 'package:rx_notifier/rx_notifier.dart';

import '../features/features_checkconnect_presenter.dart';
import 'check_connect_state.dart';

class CheckConnectReducer extends RxReducer {
  final FeaturesCheckconnectPresenter featuresCheckconnectPresenter;
  CheckConnectReducer(this.featuresCheckconnectPresenter) {
    on(() => [checarConnecaoAction], _checkConnectReducer);
    on(() => [twoPlusTowAction], _twoPlusTowReducer);
  }

  void _checkConnectReducer() async {
    final status = featuresCheckconnectPresenter.checkConnect(
      NoParams(),
    );
    checarConeccaoState.value = await status;
  }

  void _twoPlusTowReducer() async {
    final status = featuresCheckconnectPresenter.twoPlusTow(
      NoParams(),
    );
    twoPlusTowState.value = await status;
  }

  @override
  void dispose() {
    checarConeccaoState.value = null;
    twoPlusTowState.value = null;
    super.dispose();
  }
}
