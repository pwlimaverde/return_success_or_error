import 'package:return_success_or_error/return_success_or_error.dart';

/// Conjunto **fechado** de erros de uma "feature" de teste — o equivalente Dart
/// do `union` usado na versão C#. Por ser `sealed`, o `switch` sobre ele é
/// exaustivo: acrescentar um caso aqui quebra a compilação de todo consumo que
/// não o trate.
sealed class TestError extends AppError {
  const TestError(super.message);
}

final class NotFoundError extends TestError {
  const NotFoundError(super.message);
}

final class ValidationError extends TestError {
  const ValidationError(super.message);
}

final class UnexpectedError extends TestError {
  const UnexpectedError(super.message);
}

/// Lê a mensagem do erro por `switch` **exaustivo, sem braço `default`** — é a
/// prova prática de que o conjunto de erros é fechado.
String textOf(TestError error) => switch (error) {
  NotFoundError(:final message) => message,
  ValidationError(:final message) => message,
  UnexpectedError(:final message) => message,
};

/// Parâmetros de teste: só dados e imutáveis, então atravessam a fronteira do
/// isolate com segurança.
final class TestParams extends Parameters {
  final String nome;
  final bool sucesso;

  const TestParams({this.nome = 'teste', this.sucesso = true});
}
