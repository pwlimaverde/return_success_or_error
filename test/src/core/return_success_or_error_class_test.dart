// import 'package:flutter_test/flutter_test.dart';
// import 'package:return_success_or_error/src/interfaces/errors.dart';
// import 'package:return_success_or_error/src/core/return_success_or_error.dart';

// void main() {
//   test('Deve retornar o resultado ReturnSuccessOrError sucesso', () {
//     final resultSucesso = SuccessReturn<int>(
//       success: 2,
//     );

//     final status = resultSucesso.status;
//     print(status);
//     final result = resultSucesso.result;
//     print(result);

//     expect(status, equals(StatusResult.success));
//     expect(result, isA<int>());
//     expect(result, equals(2));
//   });

//   test('Deve retornar o resultado ReturnSuccessOrError errot', () {
//     final resultError = ErrorReturn(
//       error: ErrorReturnResult(
//         message: "teste error",
//       ),
//     );

//     final status = resultError.status;
//     print(status);
//     final error = resultError.result;
//     print(error);

//     expect(status, equals(StatusResult.error));
//     expect(error, isA<AppError>());
//   });
// }
