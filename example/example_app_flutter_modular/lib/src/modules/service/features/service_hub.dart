
import 'package:connectivity_plus/connectivity_plus.dart';

import '../service_binding.dart';

/// Repositório que armazena as instâncias dos serviços
final class ServiceHub {
  static ServiceHub? _instance;
  late Connectivity connectivity;

  ServiceHub._();
  
  factory ServiceHub() {
    _instance ??= ServiceHub._();
    return _instance!;
  }
  static ServiceHub get to =>
      autoInjector.get<ServiceHub>();
}