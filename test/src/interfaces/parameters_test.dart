import 'package:return_success_or_error/src/interfaces/errors.dart';
import 'package:return_success_or_error/src/interfaces/parameters.dart';
import 'package:test/test.dart';

class ParametersSalvarHeader implements ParametersReturnResult {
  @override
  final AppError error;

  final String doc;
  final String nome;
  final int prioridade;
  final Map<String, int> corHeader;
  final String user;

  ParametersSalvarHeader({
    required this.doc,
    required this.nome,
    required this.prioridade,
    required this.corHeader,
    required this.user,
    required this.error,
  });
}

void main() {
  test('Deve retornar o resultado dos Parâmetros', () {
    final parameters = ParametersSalvarHeader(
      corHeader: const {
        "r": 60,
        "g": 60,
        "b": 60,
      },
      doc: 'testedoc',
      nome: 'novidades',
      prioridade: 1,
      user: 'paulo',
      error: const ErrorGeneric(message: "teste parrametros"),
    );

    expect(parameters.doc, equals('testedoc'));
    expect(parameters.prioridade, isA<int>());
    expect(parameters.prioridade, equals(1));
  });

  group('NoParams', () {
    test('sem error usa um ErrorGeneric default', () {
      final params = NoParams();

      expect(params, isA<ParametersReturnResult>());
      expect(params.error, isA<ErrorGeneric>());
      expect(params.error.message, equals("NoParams: unspecified generic error"));
    });

    test('com error usa o fornecido', () {
      final params = NoParams(error: const ErrorGeneric(message: "meu erro"));

      expect(params.error.message, equals("meu erro"));
    });
  });
}
