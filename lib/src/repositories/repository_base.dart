import 'package:meta/meta.dart';

import '../core/return_success_or_error.dart';
import '../datasources/datasource.dart';
import '../parameters/parameters.dart';
import 'repository.dart';

/// Implementação base da fronteira: chama o [Datasource] dentro de um
/// `try/catch` e traduz a exceção técnica em um erro do conjunto fechado da
/// feature via [mapError].
///
/// A subclasse fornece **apenas** o [mapError]; o datasource fica **privado** e
/// nunca é acessado por ela.
///
/// ```dart
/// final class SalesRepository
///     extends RepositoryBase<List<String>, SalesParameters, SalesError> {
///   SalesRepository({required super.datasource});
///
///   @override
///   SalesError mapError(
///     Object exception,
///     StackTrace stackTrace,
///     SalesParameters parameters,
///   ) => switch (exception) {
///     FormatException() => CsvMalformed('CSV inválido: $exception'),
///     TimeoutException() => SalesUnavailable('Tempo esgotado'),
///     _ => SalesUnexpected('Falha inesperada: $exception'),
///   };
/// }
/// ```
abstract base class RepositoryBase<TData, TParams extends Parameters, TError>
    implements Repository<TData, TParams, TError> {
  final Datasource<TData, TParams> _datasource;

  /// O datasource é recebido como private named parameter (Dart 3.12): o
  /// chamador usa o nome público `datasource`, mas o campo permanece privado.
  /// A subclasse encaminha com `{required super.datasource}`.
  const RepositoryBase({required this._datasource});

  /// Chama a fonte e devolve o resultado já tratado: `Success` com o dado bruto,
  /// ou `Failure` com a exceção traduzida por [mapError].
  ///
  /// **Nenhuma exceção da fonte escapa daqui** — é essa garantia que permite ao
  /// usecase tratar o fetch sem `try/catch`.
  @override
  Future<ReturnSuccessOrError<TData, TError>> call(TParams parameters) async {
    try {
      return Success(await _datasource(parameters));
    } catch (exception, stackTrace) {
      return Failure(mapError(exception, stackTrace, parameters));
    }
  }

  /// Traduz uma exceção da fonte de dados em um erro do conjunto fechado da
  /// feature.
  ///
  /// **Abstrato de propósito:** como não existe mais um erro universal que a
  /// base possa fabricar, o repositório é obrigado a mapear *toda* exceção para
  /// um caso previsto de [TError]. Combinado ao consumo exaustivo do resultado,
  /// isso garante que tudo o que a camada de dados pode produzir está
  /// contemplado no tratamento final. Costuma ser um `switch` sobre o tipo da
  /// exceção com um braço `_` caindo no caso "inesperado" da feature.
  ///
  /// Recebe também o [stackTrace] e os [parameters] como contexto. O stack trace
  /// é entregue porque, em Dart, ele **não viaja dentro da exceção** (diferente
  /// do `Exception.StackTrace` do .NET): se a fronteira o descartasse no
  /// `catch`, a origem da falha se perderia para sempre. Ignorá-lo é normal em
  /// mapeamentos simples; ele existe para quem precisa reportá-lo (Sentry,
  /// Crashlytics, log estruturado).
  @protected
  TError mapError(Object exception, StackTrace stackTrace, TParams parameters);
}
