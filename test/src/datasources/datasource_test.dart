import 'package:return_success_or_error/return_success_or_error.dart';
import 'package:test/test.dart';

import '../../test_fixtures.dart';

/// Datasource "burro": devolve o dado bruto, sem conhecer o domínio.
final class FakeDatasource implements Datasource<int, TestParams> {
  final int valor;

  const FakeDatasource(this.valor);

  @override
  Future<int> call(TestParams parameters) async => valor;
}

/// Datasource que falha: deixa a exceção **técnica** subir crua, sem traduzir
/// para nenhum erro de domínio.
final class FalhaDatasource implements Datasource<int, TestParams> {
  const FalhaDatasource();

  @override
  Future<int> call(TestParams parameters) async =>
      throw const FormatException('payload inválido');
}

void main() {
  group('Datasource', () {
    test('Deve retornar o dado bruto tipado', () async {
      expect(await const FakeDatasource(42)(const TestParams()), equals(42));
    });

    test('Deve propagar a exceção técnica crua, sem traduzi-la', () async {
      // O contrato mudou na v3: o datasource não faz mais `throw
      // parameters.error` — traduzir é responsabilidade do Repository.
      // `expectLater` + await: a falha é assíncrona, e sem aguardar o matcher
      // o teste terminaria antes de verificar o throw.
      await expectLater(
        const FalhaDatasource()(const TestParams()),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
