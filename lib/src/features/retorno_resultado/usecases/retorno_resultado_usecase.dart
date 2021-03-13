import '../../../../retorno_success_ou_error_package.dart';
import '../../../utilitarios/parameters.dart';

class ReturnResultUsecase<T> extends UseCase<T, ParametersReturnResult> {
  final Repository<T, ParametersReturnResult> repository;

  ReturnResultUsecase({required this.repository});

  @override
  Future<ReturnSuccessOrError<T>> call({
    required ParametersReturnResult parameters,
  }) async {
    try {
      final result = await returnRepository(
        repository: repository,
        error: ErroReturnResult(
          message: "${parameters.messageError} Cod.01-1",
        ),
        parameters: parameters,
      );
      return result;
    } catch (e) {
      return ErrorReturn(
        error: ErroReturnResult(
          message: "${e.toString()} - ${parameters.messageError} Cod.01-2",
        ),
      );
    }
  }
}
