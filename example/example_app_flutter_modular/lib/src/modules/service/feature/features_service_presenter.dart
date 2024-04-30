import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:return_success_or_error/return_success_or_error.dart';

import '../service_module.dart';
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

  Future<Unit> widgetsFlutterBinding(NoParams params) async {
    final data = await _widgetsFlutterBindingUsecase(params);
    switch (data) {
      case SuccessReturn<Unit>():
        return unit;
      case ErrorReturn<Unit>():
        throw data.result.message;
    }
  }

  Future<Unit> connectivityUsecase(NoParams params) async {
    final data = await _connectivityUsecase(params);
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
