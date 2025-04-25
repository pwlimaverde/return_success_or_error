import 'package:connectivity_plus/connectivity_plus.dart';

import '../service_binding.dart';

final class ServiceHub {
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
