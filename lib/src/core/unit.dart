import 'package:meta/meta.dart';

/// Representa a **ausência de valor de retorno** — a operação terminou bem, mas
/// não produz payload (o `void` como resultado).
///
/// Existe porque `void` não é um argumento de tipo útil: `Success<void, E>` não
/// carrega nada que se possa inspecionar. Use `Success(unit)`.
@immutable
final class Unit {
  const Unit();

  @override
  String toString() => 'Unit - void';
}

/// Instância singleton de [Unit].
const Unit unit = Unit();
