/// Auxiliary singleton that standardizes the initialization of basic services
/// and their dependencies.
final class Service {
  static Service? _instance;

  Service._();

  /// Runs the dependency-registration routine (e.g. DI container setup).
  Future<void> initDependencies(
    Future<void> Function() registerDependencies,
  ) async {
    await registerDependencies();
  }

  /// Starts the given services in parallel, completing when all of them do.
  Future<void> initServices(List<Future<dynamic>> services) async {
    await Future.wait(services);
  }

  /// Singleton accessor.
  static Service get to => _instance ??= Service._();
}
