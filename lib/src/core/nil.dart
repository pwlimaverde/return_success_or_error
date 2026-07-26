import 'package:meta/meta.dart';

/// Representa `null` como **resultado válido e esperado**.
///
/// Distingue "o `null` é a resposta correta" (ex.: a busca não encontrou o
/// registro, e isso não é erro) de "não há valor porque falhou". Use
/// `Success(nil)`.
@immutable
final class Nil {
  const Nil();

  @override
  String toString() => 'Nil - null';
}

/// Instância singleton de [Nil].
const Nil nil = Nil();
