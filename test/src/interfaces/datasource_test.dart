import 'package:flutter_test/flutter_test.dart';
import 'package:return_success_or_error/src/interfaces/errors.dart';
import 'package:return_success_or_error/src/core/parameters.dart';
import 'package:return_success_or_error/src/interfaces/datasource.dart';

class ExternalMock<bool> {
  final bool? teste;
  ExternalMock({
    this.teste,
  });
  bool returnBool() {
    if (teste != null) {
      return teste!;
    } else {
      throw Exception();
    }
  }
}

class TesteDataSourceMock extends Datasource<bool> {
  final ExternalMock<bool> external;

  TesteDataSourceMock({required this.external});

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
    final result = await TesteDataSourceMock(
      external: ExternalMock(teste: true),
    )(
      parameters: NoParams(
        error: ErrorReturnResult(
          message: "teste error direto datasource",
        ),
        nameFeature: "Teste Usecase",
        showRuntimeMilliseconds: true,
        isIsolate: true,
      ),
    );
    print("teste result - $result");
    expect(result, isA<bool>());
  });

  test('Deve retornar um success com false', () async {
    final result = await TesteDataSourceMock(
      external: ExternalMock(teste: false),
    )(
      parameters: NoParams(
        error: ErrorReturnResult(
          message: "teste error direto datasource",
        ),
        nameFeature: "Teste Usecase",
        showRuntimeMilliseconds: true,
        isIsolate: true,
      ),
    );
    print("teste result - $result");
    expect(result, isA<bool>());
  });

  test('Deve retornar um erro', () async {
    expect(
        () async => await TesteDataSourceMock(
              external: ExternalMock(),
            )(
              parameters: NoParams(
                error: ErrorReturnResult(
                  message: "teste error direto datasource",
                ),
                nameFeature: "Teste Usecase",
                showRuntimeMilliseconds: true,
                isIsolate: true,
              ),
            ),
        throwsA(isA<Exception>()));
  });
}
