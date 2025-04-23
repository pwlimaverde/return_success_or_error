import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:example_app_flutter_modular/src/modules/service/features/service_hub.dart';
import 'package:example_app_flutter_modular/src/modules/service/service_binding.dart';
import 'package:return_success_or_error/return_success_or_error.dart';
import 'connectivity/domain/usecase/connectivity_usecase.dart';
import 'widgets_flutter_binding/domain/usecase/widgets_flutter_binding_usecase.dart';

final class FeaturesServiceComposer {
  static FeaturesServiceComposer? _instance;

  final ServiceHub _serviceHub;
  final WidUsecase _widgetsFlutterBindingUsecase;
  final ConnectUsecase _connectivityUsecase;

  FeaturesServiceComposer._({
    required ServiceHub serviceHub,
    required WidUsecase widgetsFlutterBindingUsecase,
    required ConnectUsecase connectivityUsecase,
  }) : _widgetsFlutterBindingUsecase = widgetsFlutterBindingUsecase,
       _connectivityUsecase = connectivityUsecase,
       _serviceHub = serviceHub;

  factory FeaturesServiceComposer({
    required ServiceHub serviceHub,
    required WidUsecase widgetsFlutterBindingUsecase,
    required ConnectUsecase connectivityUsecase,
  }) {
    _instance ??= FeaturesServiceComposer._(
      serviceHub: serviceHub,
      widgetsFlutterBindingUsecase: widgetsFlutterBindingUsecase,
      connectivityUsecase: connectivityUsecase,
    );
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

  static FeaturesServiceComposer get to =>
      autoInjector.get<FeaturesServiceComposer>();
}
