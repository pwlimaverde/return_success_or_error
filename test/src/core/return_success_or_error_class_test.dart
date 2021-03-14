import 'package:flutter_test/flutter_test.dart';
import 'package:return_success_or_error/src/core/errors.dart';
import 'package:return_success_or_error/src/core/return_success_or_error_class.dart';

void main() {
  test('Deve retornar um success', () {
    final result = SuccessReturn(result: "teste success");
    print(result.fold(
      success: (value) => value.result,
      error: (value) => value.error,
    ));
    expect(result, isA<ReturnSuccessOrError<String>>());
  });

  test('Deve retornar um success com o result da String', () {
    final result = SuccessReturn(result: "teste success");
    print(result.fold(
      success: (value) => value.result,
      error: (value) => value.error,
    ));

    expect(
        result.fold(
          success: (value) => value.result,
          error: (value) => value.error,
        ),
        "teste success");
  });

  test('Deve retornar um errorr', () {
    final result = ErrorReturn(
      error: ErroReturnResult(
        message: "teste error",
      ),
    );
    print(result.fold(
      success: (value) => value.result,
      error: (value) => value.error,
    ));
    expect(result, isA<ErrorReturn>());
  });
}
