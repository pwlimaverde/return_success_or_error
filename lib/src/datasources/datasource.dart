import '../parameters/parameters.dart';

/// Contrato da fonte de dados — o *port* de infraestrutura.
///
/// É a camada **burra**: executa a chamada externa (I/O) e devolve o **dado
/// bruto**, **ou lança** a exceção técnica que ocorreu. Não conhece o domínio e
/// **não traduz erros** — traduzir exceção técnica em erro de domínio é
/// responsabilidade da fronteira (`RepositoryBase.mapError`).
///
/// [TData] é o tipo cru devolvido pela chamada (ex.: `bool`, um DTO, uma
/// `List`); [TParams] é o tipo concreto dos parâmetros.
///
/// ```dart
/// final class ConnectivityDatasource
///     implements Datasource<bool, NoParams> {
///   final Connectivity _connectivity;
///
///   const ConnectivityDatasource(this._connectivity);
///
///   @override
///   Future<bool> call(NoParams parameters) async {
///     // Sem try/catch: a exceção sobe crua e o Repository a traduz.
///     final result = await _connectivity.checkConnectivity();
///     return !result.contains(ConnectivityResult.none);
///   }
/// }
/// ```
///
/// > **Mudança em relação à v2:** o datasource não faz mais
/// > `throw parameters.error`. Ele não precisa (nem deve) conhecer o erro de
/// > domínio: deixa a exceção original subir, com todo o seu contexto, para o
/// > `mapError` do repositório decidir em qual erro da feature ela se traduz.
abstract interface class Datasource<TData, TParams extends Parameters> {
  /// Executa a chamada externa e devolve o dado bruto, ou **lança** a exceção
  /// técnica em caso de falha.
  Future<TData> call(TParams parameters);
}
