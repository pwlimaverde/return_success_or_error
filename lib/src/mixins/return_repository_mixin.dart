// import '../core/parameters.dart';
// import '../features/return_result/repositories/return_result_repository.dart';
// import '../interfaces/errors.dart';

// mixin ReturnRepositoryMixin<TypeDatasource> {
//   Future<({TypeDatasource? result, AppError? error})> returnRepository({
//     required ParametersReturnResult parameters,
//     required ReturnResultRepository<TypeDatasource> repository,
//   }) async {
//     final String messageError = parameters.basic.error.message;
//     try {
//       final result = await repository(
//         parameters: parameters,
//       );
//       return result;
//     } catch (e) {
//       return (
//         result: null,
//         error: parameters.basic.error
//           ..message = "$messageError. \n Cod. 02-1 --- Catch: $e",
//       );
//     }
//   }
// }
