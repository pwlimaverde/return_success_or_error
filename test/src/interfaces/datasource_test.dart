import 'package:flutter_test/flutter_test.dart';
import 'package:return_success_or_error/src/interfaces/parameters.dart';
import 'package:return_success_or_error/src/interfaces/datasource.dart';
import 'package:return_success_or_error/src/interfaces/errors.dart';

class ParametersSalvarHeader implements ParametersReturnResult {
  final String nome;

  ParametersSalvarHeader({
    required this.nome,
  });

  @override
  AppError get error => ErrorGeneric(message: "teste parrametros");
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
  Future<bool> call(
    ParametersSalvarHeader parameters,
  ) async {
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
      ParametersSalvarHeader(nome: 'Teste UsecaseBase'),
    );
    print("teste result - $result");
    expect(result, isA<bool>());
  });

  test('Deve retornar um success com false', () async {
    final result = await TesteDataSourceMock(
      external: ExternalMock(teste: false),
    )(
      ParametersSalvarHeader(nome: 'Teste UsecaseBase'),
    );
    print("teste result - $result");
    expect(result, isA<bool>());
  });

  test('Deve retornar um erro', () async {
    expect(
        () async => await TesteDataSourceMock(
              external: ExternalMock(),
            )(
              ParametersSalvarHeader(nome: 'Teste UsecaseBase'),
            ),
        throwsA(isA<Exception>()));
  });
}
