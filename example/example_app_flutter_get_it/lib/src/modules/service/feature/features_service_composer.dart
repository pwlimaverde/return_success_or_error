import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:return_success_or_error/return_success_or_error.dart';

import 'connectivity/domain/usecase/connectivity_usecase.dart';
import 'service_hub.dart';
import 'widgets_flutter_binding/domain/usecase/widgets_flutter_binding_usecase.dart';

final class FeaturesServicePresenter {
  static FeaturesServicePresenter? _instance;

  final ServiceHub _serviceHub;
  final WidUsecase _widgetsFlutterBindingUsecase;
  final ConnectUsecase _connectivityUsecase;

  FeaturesServicePresenter._({
    required ServiceHub serviceHub,
    required WidUsecase widgetsFlutterBindingUsecase,
    required ConnectUsecase connectivityUsecase,
  })  : _widgetsFlutterBindingUsecase = widgetsFlutterBindingUsecase,
        _serviceHub = serviceHub,
        _connectivityUsecase = connectivityUsecase;

  factory FeaturesServicePresenter({
    required ServiceHub serviceHub,
    required WidUsecase widgetsFlutterBindingUsecase,
    required ConnectUsecase connectivityUsecase,
  }) {
    _instance ??= FeaturesServicePresenter._(
        serviceHub: serviceHub,
        widgetsFlutterBindingUsecase: widgetsFlutterBindingUsecase,
        connectivityUsecase: connectivityUsecase);
    return _instance!;
  }

  Future<Unit> widgetsFlutterBinding() async {
    final data = await _widgetsFlutterBindingUsecase(NoParams());
    switch (data) {
      case SuccessReturn<Unit>():
        return unit;
      case ErrorReturn<Unit>():
        throw data.result.message;
    }
  }

  Future<Unit> connectivityUsecase() async {
    final data = await _connectivityUsecase(NoParams());
    switch (data) {
      case SuccessReturn<Connectivity>():
        _serviceHub.connectivity = data.result;
        return unit;
      case ErrorReturn<Connectivity>():
        throw data.result.message;
    }
  }

  static FeaturesServicePresenter get to =>
      GetIt.I.get<FeaturesServicePresenter>();
}
