import '../core/errors.dart';
import '../core/return_success_or_error_class.dart';
import 'datasource.dart';

abstract class Repository<R, Parameters> {
  Future<ReturnSuccessOrError<R>> call({required Parameters parameters});

  Future<ReturnSuccessOrError<R>> returnDatasource({
    required AppError error,
    required Parameters parameters,
    required Datasource<R, Parameters> datasource,
  }) async {
    try {
      final R result = await datasource(parameters: parameters);
      return SuccessReturn<R>(result: result);
    } catch (e) {
      return ErrorReturn<R>(
        error: error,
      );
    }
  }
}
