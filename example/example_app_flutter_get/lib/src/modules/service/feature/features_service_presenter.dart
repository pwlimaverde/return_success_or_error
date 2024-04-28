import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:return_success_or_error/return_success_or_error.dart';

final class FeaturesServicePresenter {
  static FeaturesServicePresenter? _instance;
  late Connectivity connectivity;

  final UsecaseBaseCallData<Unit, WidgetsBinding> _widgetsFlutterBindingUsecase;
  final UsecaseBase<Connectivity> _connectivityUsecase;

  FeaturesServicePresenter._({
    required UsecaseBaseCallData<Unit, WidgetsBinding>
        widgetsFlutterBindingUsecase,
    required UsecaseBase<Connectivity> connectivityUsecase,
  })  : _widgetsFlutterBindingUsecase = widgetsFlutterBindingUsecase,
        _connectivityUsecase = connectivityUsecase;

  factory FeaturesServicePresenter({
    required UsecaseBaseCallData<Unit, WidgetsBinding>
        widgetsFlutterBindingUsecase,
    required UsecaseBase<Connectivity> connectivityUsecase,
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
      Get.find<FeaturesServicePresenter>();
}
