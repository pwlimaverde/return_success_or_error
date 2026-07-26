import '../core/return_success_or_error.dart';
import '../parameters/parameters.dart';

/// Contrato da camada de dados — a **fronteira** (*anti-corruption layer*) entre
/// a infraestrutura e o domínio.
///
/// Diferente do `Datasource`, que é burro e lança, o repositório **nunca propaga
/// falha de infraestrutura**: devolve sempre um [ReturnSuccessOrError] — o dado
/// bruto como `Success`, ou a exceção já traduzida em um dos erros do conjunto
/// fechado da feature ([TError]) como `Failure`.
///
/// É desta abstração que o usecase depende (DIP) — é o que o torna portável:
/// trocar a fonte de dados (HTTP por cache, real por fake no teste) não toca a
/// regra de negócio.
///
/// A implementação normal é estender `RepositoryBase`, que já faz a captura e
/// delega a tradução ao `mapError`. Implementar esta interface diretamente só é
/// necessário para um repositório que não tenha um único `Datasource` por trás
/// (ex.: compõe duas fontes, ou serve de fake em teste).
abstract interface class Repository<TData, TParams extends Parameters, TError> {
  /// Busca o dado e devolve o resultado **já tratado**.
  Future<ReturnSuccessOrError<TData, TError>> call(TParams parameters);
}
