import 'package:return_success_or_error/return_success_or_error.dart';
import 'package:test/test.dart';

import '../../test_fixtures.dart';

void main() {
  group('Parameters', () {
    test('Carrega somente dados — não expõe nenhum erro', () {
      const parameters = TestParams(nome: 'relatorio');

      expect(parameters.nome, 'relatorio');
      expect(parameters, isA<Parameters>());
    });

    test('É const, então atravessa a fronteira do isolate com segurança', () {
      expect(identical(const TestParams(), const TestParams()), isTrue);
    });
  });

  group('NoParams', () {
    test('noParams é o singleton canonicalizado', () {
      expect(identical(noParams, const NoParams()), isTrue);
      expect(noParams, isA<Parameters>());
    });

    test('toString', () {
      expect(noParams.toString(), 'NoParams');
    });
  });
}
