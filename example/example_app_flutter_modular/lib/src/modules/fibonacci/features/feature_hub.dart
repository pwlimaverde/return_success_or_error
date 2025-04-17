import 'package:return_success_or_error/return_success_or_error.dart';

final class FeatureHub implements Hub {
  static FeatureHub? _instance;

  FeatureHub._();

  factory FeatureHub() {
    _instance ??= FeatureHub._();
    return _instance!;
  }
}