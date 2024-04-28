final class Service {

   static Service? _instance;

  Service._();
  Future<void> initDependences(
      Future<void> Function() registroDependencias) async {
    await registroDependencias();
  }

  Future<void> initServices(List<Future<dynamic>> listServices) async {
    await Future.wait(listServices);
  }

  static Service get to =>
      _instance == null ? _instance = Service._() : _instance!;
}
