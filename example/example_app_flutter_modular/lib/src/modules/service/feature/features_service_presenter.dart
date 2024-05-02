import 'package:auto_injector/auto_injector.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:example_app_flutter_modular/src/modules/service/service_binding.dart';
import 'package:return_success_or_error/return_success_or_error.dart';
import 'connectivity/domain/usecase/connectivity_usecase.dart';
import 'widgets_flutter_binding/domain/usecase/widgets_flutter_binding_usecase.dart';

final class FeaturesServicePresenter {
  static FeaturesServicePresenter? _instance;
  late Connectivity connectivity;

  final WidUsecase _widgetsFlutterBindingUsecase;
  final ConnectUsecase _connectivityUsecase;

  FeaturesServicePresenter._({
    required WidUsecase widgetsFlutterBindingUsecase,
    required ConnectUsecase connectivityUsecase,
  })  : _widgetsFlutterBindingUsecase = widgetsFlutterBindingUsecase,
        _connectivityUsecase = connectivityUsecase;

  factory FeaturesServicePresenter({
    required WidUsecase widgetsFlutterBindingUsecase,
    required ConnectUsecase connectivityUsecase,
  }) {
    _instance ??= FeaturesServicePresenter._(
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
        connectivity = data.result;
        return unit;
      case ErrorReturn<Connectivity>():
        throw data.result.message;
    }
  }

  static FeaturesServicePresenter get to =>
      autoInjector.get<FeaturesServicePresenter>();
}
