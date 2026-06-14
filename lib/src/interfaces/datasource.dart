import 'parameters.dart';

/// Abstração de uma chamada externa, tipada com o dado que ela deve retornar.
///
/// [TypeDatasource] é o tipo cru devolvido pela chamada (ex.: `bool`, um DTO,
/// uma `List`). Implemente [call] envolvendo a lógica em um `try/catch`:
/// retorne o dado tipado em caso de sucesso ou faça `throw` no [AppError]
/// carregado pelo [ParametersReturnResult] em caso de falha — o
/// `resultDatasource` do usecase captura essa exceção, preserva o tipo concreto
/// do erro e enriquece a mensagem com o contexto do catch.
///
/// O parâmetro é `covariant`, então a implementação pode tipá-lo com sua própria
/// `ParametersReturnResult` concreta. Exemplo:
/// ```dart
/// final class ConnectivityDatasource implements Datasource<bool> {
///   final Connectivity _connectivity;
///   const ConnectivityDatasource(this._connectivity);
///
///   @override
///   Future<bool> call(ParametersReturnResult parameters) async {
///     try {
///       final result = await _connectivity.checkConnectivity();
///       return !result.contains(ConnectivityResult.none);
///     } catch (e) {
///       throw parameters.error.copyWith(message: "$e");
///     }
///   }
/// }
/// ```
abstract interface class Datasource<TypeDatasource> {
  /// Executa a chamada externa e devolve o dado tipado, ou faz `throw` no
  /// [AppError] dos [parameters] em caso de falha.
  Future<TypeDatasource> call(covariant ParametersReturnResult parameters);
}
