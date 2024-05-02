import 'package:return_success_or_error/return_success_or_error.dart';
import 'package:rx_notifier/rx_notifier.dart';

import '../features/features_checkconnect_presenter.dart';
import 'check_connect_state.dart';

final class CheckConnectReducer extends RxReducer {
  final FeaturesCheckconnectPresenter featuresCheckconnectPresenter;
  CheckConnectReducer(this.featuresCheckconnectPresenter) {
    on(() => [checarConnecaoAction], _checkConnectReducer);
    on(() => [twoPlusTowAction], _twoPlusTowReducer);
  }

  void _checkConnectReducer() async {
    final status = await featuresCheckconnectPresenter.checkConnect();
    checarConeccaoState.value = status;
  }

  void _twoPlusTowReducer() async {
    final status = await featuresCheckconnectPresenter.twoPlusTow();
    twoPlusTowState.value = status;
  }

  @override
  void dispose() {
    checarConeccaoState.value = null;
    twoPlusTowState.value = null;
    super.dispose();
  }
}
