import '../../../../return_success_or_error.dart';
import '../../../mixins/return_usecase_mixin.dart';

abstract base class ReturnResultUsecase<TypeUsecase, TypeDatasource>
    with ReturnUsecaseMixin<TypeDatasource> {
  final Datasource<TypeDatasource> datasource;

  ReturnResultUsecase({required this.datasource});
  Future<({TypeUsecase? result, AppError? error})> call({
    required ParametersReturnResult parameters,
  });

  // ReturnResultUsecase({
  //   required this.datasource,
  // });

  // Future<({TypeDatasource? result, AppError? error})> returResult({
  //   required ParametersReturnResult parameters,
  // }) async {
  //   final String messageError = parameters.basic.error.message;
  //   final RuntimeMilliseconds runtime = RuntimeMilliseconds();
  //   try {
  //     if (parameters.basic.showRuntimeMilliseconds) {
  //       runtime.startScore();
  //     }
  //     final result = await ReturnResultRepository(datasource: datasource)(
  //         parameters: parameters);

  //     if (parameters.basic.showRuntimeMilliseconds) {
  //       runtime.finishScore();
  //       print(
  //           "Execution Time ${parameters.basic.nameFeature}: ${runtime.calculateRuntime()}ms");
  //     }
  //     return result;
  //   } catch (e) {
  //     return (
  //       result: null,
  //       error: parameters.basic.error
  //         ..message = "$messageError - Cod. 01-1.1 --- Catch: $e",
  //     );
  //   }
  // }
}
