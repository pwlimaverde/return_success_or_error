import 'parameters.dart';

/// [Parameters] vazio, para chamadas que não exigem entrada.
///
/// Por não carregar nenhum dado, é canonicalizado como `const`: use a instância
/// compartilhada [noParams].
final class NoParams extends Parameters {
  const NoParams();

  @override
  String toString() => 'NoParams';
}

/// Instância singleton de [NoParams].
const NoParams noParams = NoParams();
