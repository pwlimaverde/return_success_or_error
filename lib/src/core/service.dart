///auxiliary class responsible for initializing basic services
final class Service {

   static Service? _instance;

  Service._();

  ///function for initializing service dependencies
  Future<void> initDependences(
      Future<void> Function() registroDependencias) async {
    await registroDependencias();
  }
  ///function for starting services
  Future<void> initServices(List<Future<dynamic>> listServices) async {
    await Future.wait(listServices);
  }

  ///singleton loading
  static Service get to =>
      _instance == null ? _instance = Service._() : _instance!;
}
