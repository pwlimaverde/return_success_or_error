import 'package:flutter_test/flutter_test.dart';
import 'package:return_success_or_error/src/core/parameters.dart';
import 'package:return_success_or_error/src/interfaces/errors.dart';

class ParametersSalvarHeader implements ParametersReturnResult {
  final String doc;
  final String nome;
  final int prioridade;
  final Map corHeader;
  final String user;

  ParametersSalvarHeader({
    required this.doc,
    required this.nome,
    required this.prioridade,
    required this.corHeader,
    required this.user,
  });

  @override
  ParametersBasic get basic => ParametersBasic(
        error: ErrorGeneric(message: "teste parrametros"),
        showRuntimeMilliseconds: true,
        nameFeature: "Teste parametros",
        isIsolate: true,
      );
}

void main() {
  test('Deve retornar o resultado dos Parâmetros', () {
    final parameters = ParametersSalvarHeader(
      corHeader: {
        "r": 60,
        "g": 60,
        "b": 60,
      },
      doc: 'testedoc',
      nome: 'novidades',
      prioridade: 1,
      user: 'paulo',
    );

    print(parameters.corHeader);

    expect(parameters.doc, equals('testedoc'));
    expect(parameters.prioridade, isA<int>());
    expect(parameters.prioridade, equals(1));
    expect(parameters.basic.isIsolate, equals(true));
    expect(parameters.basic.nameFeature, equals("Teste parametros"));
  });
}
