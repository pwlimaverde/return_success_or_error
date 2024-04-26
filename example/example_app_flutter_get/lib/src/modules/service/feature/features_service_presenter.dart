import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:return_success_or_error/return_success_or_error.dart';

final class FeaturesServicePresenter {
  final UsecaseBaseCallData<Unit, WidgetsBinding> _widgetsFlutterBindingUsecase;

  FeaturesServicePresenter({
    required UsecaseBaseCallData<Unit, WidgetsBinding>
        widgetsFlutterBindingUsecase,
  }) : _widgetsFlutterBindingUsecase = widgetsFlutterBindingUsecase;

  Future<Unit?> widgetsFlutterBinding(NoParams params) async {
    final data = await _widgetsFlutterBindingUsecase(params);
    switch (data) {
      case SuccessReturn<Unit>():
        print("Serviço iniciado com sussesso");
        return unit;
      case ErrorReturn<Unit>():
        throw data.result.message;
    }
  }

  static FeaturesServicePresenter get to =>
      Get.find<FeaturesServicePresenter>();
}
