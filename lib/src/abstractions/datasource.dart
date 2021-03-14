abstract class Datasource<R, Parameters> {
  Future<R> call({required Parameters parameters});
}
