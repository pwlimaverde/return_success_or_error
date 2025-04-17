import 'package:rx_notifier/rx_notifier.dart';

import '../features/features_composer.dart';
import 'check_connect_state.dart';

final class CheckConnectReducer extends RxReducer {
  final FeaturesComposer featuresComposer;
  CheckConnectReducer(this.featuresComposer) {
    on(() => [checarConnecaoAction], _checkConnectReducer);
    on(() => [twoPlusTowAction], _twoPlusTowReducer);
  }

  void _checkConnectReducer() async {
    final status = await featuresComposer.checkConnect();
    checarConeccaoState.value = status;
  }

  void _twoPlusTowReducer() async {
    final status = await featuresComposer.twoPlusTow();
    twoPlusTowState.value = status;
  }

  @override
  void dispose() {
    checarConeccaoState.value = null;
    twoPlusTowState.value = null;
    super.dispose();
  }
}
