import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:return_success_or_error/return_success_or_error.dart';

import '../service_binding.dart';

final class ServiceHub implements Hub {
  late Connectivity connectivity;
  static ServiceHub? _instance;
  ServiceHub._();

  factory ServiceHub() {
    _instance ??= ServiceHub._();
    return _instance!;
  }

  static ServiceHub get to =>
      autoInjector.get<ServiceHub>();
}
