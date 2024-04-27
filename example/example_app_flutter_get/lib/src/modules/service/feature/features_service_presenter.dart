import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:return_success_or_error/return_success_or_error.dart';

final class FeaturesServicePresenter {
  static FeaturesServicePresenter? _instance;

  final UsecaseBaseCallData<Unit, WidgetsBinding> _widgetsFlutterBindingUsecase;

  FeaturesServicePresenter._({
    required UsecaseBaseCallData<Unit, WidgetsBinding>
        widgetsFlutterBindingUsecase,
  }) : _widgetsFlutterBindingUsecase = widgetsFlutterBindingUsecase;

  factory FeaturesServicePresenter({
    required UsecaseBaseCallData<Unit, WidgetsBinding>
        widgetsFlutterBindingUsecase,
  }) {
    _instance ??= FeaturesServicePresenter._(
      widgetsFlutterBindingUsecase: widgetsFlutterBindingUsecase,
    );
    return _instance!;
  }

  Future<Unit?> widgetsFlutterBinding(NoParams params) async {
    final data = await _widgetsFlutterBindingUsecase(params);
    switch (data) {
      case SuccessReturn<Unit>():
        return unit;
      case ErrorReturn<Unit>():
        throw data.result.message;
    }
  }

  static FeaturesServicePresenter get to =>
      Get.find<FeaturesServicePresenter>();
}
