import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';



final class ServiceHub {
  late Connectivity connectivity;
  static ServiceHub? _instance;
  ServiceHub._();

  factory ServiceHub() {
    _instance ??= ServiceHub._();
    return _instance!;
  }

  static ServiceHub get to =>
      GetIt.I.get<ServiceHub>();
}
