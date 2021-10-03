import 'package:flutter_test/flutter_test.dart';
import 'package:return_success_or_error/return_success_or_error.dart';
import 'package:return_success_or_error/src/core/errors.dart';
import 'package:return_success_or_error/src/core/parameters.dart';

class ExternalMock<bool> {
  final bool teste;
  ExternalMock({
    required this.teste,
  });
  bool returnBool() {
    return teste;
  }
}

class TesteDataSourseMock extends Datasource<bool> {
  final ExternalMock<bool> external;

  TesteDataSourseMock({required this.external});

  @override
  Future<bool> call({
    required ParametersReturnResult parameters,
  }) async {
    try {
      return external.returnBool();
    } catch (e) {
      throw Exception();
    }
  }
}

void main() {
  test('Deve retornar um success com true', () async {
    final result = await TesteDataSourseMock(
      external: ExternalMock(teste: true),
    )(
      parameters: NoParams(
        error: ErrorReturnResult(
          message: "teste error direto datasource",
        ),
        nameFeature: "Teste Usecase",
        showRuntimeMilliseconds: true,
      ),
    );
    print("teste result - ${result}");
    expect(result, isA<bool>());
  });

  test('Deve retornar um success com false', () async {
    final result = await TesteDataSourseMock(
      external: ExternalMock(teste: false),
    )(
      parameters: NoParams(
        error: ErrorReturnResult(
          message: "teste error direto datasource",
        ),
        nameFeature: "Teste Usecase",
        showRuntimeMilliseconds: true,
      ),
    );
    print("teste result - ${result}");
    expect(result, isA<bool>());
  });
}
