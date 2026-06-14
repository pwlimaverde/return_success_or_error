import 'package:meta/meta.dart';

/// Contrato de erro imutável. Implementa [Exception] e expõe uma [message].
///
/// É o tipo padronizado de erro de todo o pacote: qualquer falha resolve em um
/// [AppError], carregado pelos parâmetros e devolvido dentro de um `ErrorReturn`.
///
/// As implementações devem ser imutáveis: para enriquecer um erro (por exemplo,
/// anexar contexto enquanto ele sobe pelas camadas), use [copyWith] para
/// produzir uma nova instância em vez de mutar a existente. A interface é
/// anotada com `@immutable`, então o analyzer sinaliza qualquer implementação
/// que guarde estado mutável.
///
/// Por ser uma interface consumida com `implements`, ela só consegue obrigar o
/// contrato abstrato — [message] e [copyWith]. Ela **não** entrega nenhum
/// comportamento padrão: igualdade por valor (`==`/`hashCode`) e um `toString`
/// amigável **não** são herdados, então todo implementador cai nas versões
/// baseadas em identidade de [Object], a menos que as sobrescreva por conta
/// própria (como o [ErrorGeneric] faz). Sobrescreva-as no seu erro custom quando
/// quiser igualdade por valor (útil em asserts de teste) ou um `toString`
/// legível.
@immutable
abstract interface class AppError implements Exception {
  /// Descrição do erro, legível por humanos.
  String get message;

  /// Retorna uma cópia deste erro, opcionalmente substituindo a [message].
  ///
  /// É o mecanismo de enriquecimento: como o `copyWith` é polimórfico, o tipo
  /// concreto do erro é preservado (um `ApiError` continua `ApiError`).
  AppError copyWith({String? message});
}

/// Implementação concreta padrão de [AppError].
///
/// Pronta para uso quando não há necessidade de um erro de domínio específico.
/// Compara por valor: dois [ErrorGeneric] com a mesma [message] são iguais, o
/// que mantém asserts e comparações de erro previsíveis. O `toString` usa o
/// [runtimeType] e a [message] (`"$runtimeType - $message"`).
@immutable
final class ErrorGeneric implements AppError {
  @override
  final String message;

  const ErrorGeneric({required this.message});

  @override
  ErrorGeneric copyWith({String? message}) =>
      ErrorGeneric(message: message ?? this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ErrorGeneric && other.message == message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => "$runtimeType - $message";
}
