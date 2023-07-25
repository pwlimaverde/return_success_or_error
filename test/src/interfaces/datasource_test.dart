import 'package:flutter_test/flutter_test.dart';
import 'package:return_success_or_error/src/core/parameters.dart';
import 'package:return_success_or_error/src/interfaces/datasource.dart';
import 'package:return_success_or_error/src/interfaces/errors.dart';

class ParametersSalvarHeader implements ParametersReturnResult {
  final String nome;

  ParametersSalvarHeader({
    required this.nome,
  });

  @override
  ParametersBasic get basic => ParametersBasic(
        error: ErrorGeneric(message: "teste parrametros"),
        showRuntimeMilliseconds: true,
        nameFeature: "Teste parametros",
        isIsolate: true,
      );
}

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

class TesteDataSourceMock implements Datasource<bool> {
  final ExternalMock<bool> external;

  TesteDataSourceMock({required this.external});

  @override
  Future<bool> call({
    required ParametersSalvarHeader parameters,
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
      parameters: ParametersSalvarHeader(nome: 'Teste UsecaseBase'),
    );
    print("teste result - $result");
    expect(result, isA<bool>());
  });

  test('Deve retornar um success com false', () async {
    final result = await TesteDataSourceMock(
      external: ExternalMock(teste: false),
    )(
      parameters: ParametersSalvarHeader(nome: 'Teste UsecaseBase'),
    );
    print("teste result - $result");
    expect(result, isA<bool>());
  });

  test('Deve retornar um erro', () async {
    expect(
        () async => await TesteDataSourceMock(
              external: ExternalMock(),
            )(
              parameters: ParametersSalvarHeader(nome: 'Teste UsecaseBase'),
            ),
        throwsA(isA<Exception>()));
  });
}
