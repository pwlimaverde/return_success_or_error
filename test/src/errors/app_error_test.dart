import 'package:return_success_or_error/return_success_or_error.dart';
import 'package:test/test.dart';

import '../../test_fixtures.dart';

/// Erro com campo adicional: precisa sobrescrever `==`/`hashCode` para que o
/// campo entre na comparação (a igualdade herdada olha só runtimeType+message).
final class ErrorComCampo extends AppError {
  final int codigo;

  const ErrorComCampo(super.message, this.codigo);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ErrorComCampo &&
          other.message == message &&
          other.codigo == codigo;

  @override
  int get hashCode => Object.hash(message, codigo);
}

void main() {
  group('ErrorGeneric', () {
    test('Deve expor a message recebida', () {
      expect(const ErrorGeneric('falhou').message, 'falhou');
    });

    test('Deve ser um Exception', () {
      expect(const ErrorGeneric('falhou'), isA<Exception>());
    });

    test('toString usa o runtimeType herdado de AppError', () {
      expect(const ErrorGeneric('falhou').toString(), 'ErrorGeneric - falhou');
    });

    test('Deve comparar por valor sem reimplementar nada', () {
      expect(const ErrorGeneric('x'), equals(const ErrorGeneric('x')));
      expect(
        const ErrorGeneric('x').hashCode,
        equals(const ErrorGeneric('x').hashCode),
      );
      expect(const ErrorGeneric('x'), isNot(equals(const ErrorGeneric('y'))));
    });
  });

  group('AppError como base dos erros da feature', () {
    test('Erros da feature herdam message, toString e igualdade', () {
      expect(const NotFoundError('sumiu').message, 'sumiu');
      expect(const NotFoundError('sumiu').toString(), 'NotFoundError - sumiu');
      expect(
        const NotFoundError('sumiu'),
        equals(const NotFoundError('sumiu')),
      );
    });

    test('Tipos diferentes com a mesma message NÃO são iguais', () {
      expect(
        const NotFoundError('x'),
        isNot(equals(const ValidationError('x'))),
      );
    });

    test('Subclasse com campo extra compara incluindo o campo', () {
      expect(const ErrorComCampo('x', 1), equals(const ErrorComCampo('x', 1)));
      expect(
        const ErrorComCampo('x', 1),
        isNot(equals(const ErrorComCampo('x', 2))),
      );
    });

    test('textOf lê qualquer caso do conjunto fechado', () {
      expect(textOf(const NotFoundError('a')), 'a');
      expect(textOf(const ValidationError('b')), 'b');
      expect(textOf(const UnexpectedError('c')), 'c');
    });
  });
}
