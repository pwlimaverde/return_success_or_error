import 'package:return_success_or_error/return_success_or_error.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../features/features_checkconnect_presenter.dart';

final class CheckConnectController {
  final FeaturesCheckconnectPresenter featuresCheckconnectPresenter;

  CheckConnectController({
    required this.featuresCheckconnectPresenter,
  });

  final _checarConeccaoState = signal<String?>(null);
  String? get checarConeccaoState => _checarConeccaoState.value;

  final _twoPlusTowState = signal<int?>(null);
  int? get twoPlusTowState => _twoPlusTowState.value;

  void checkConnect() async {
    final status = await featuresCheckconnectPresenter.checkConnect(
      NoParams(),
    );
    _checarConeccaoState.value = status;
  }

  void twoPlusTow() async {
    final status = await featuresCheckconnectPresenter.twoPlusTow(
      NoParams(),
    );
    _twoPlusTowState.value = status;
  }
}
