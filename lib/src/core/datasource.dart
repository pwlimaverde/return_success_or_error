abstract class Datasource<R, Parametros> {
  Future<R> call({required Parametros parametros});
}
