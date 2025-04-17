import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:return_success_or_error/return_success_or_error.dart';

import '../service_binding.dart';

final class ServiceHub extends Hub {
  late Connectivity connectivity;
  ServiceHub._();

  factory ServiceHub() {
    Hub.instance ??= ServiceHub._();
    return Hub.instance! as ServiceHub;
  }

  static ServiceHub get to =>
      autoInjector.get<ServiceHub>();
}
