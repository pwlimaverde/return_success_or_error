import 'package:return_success_or_error/return_success_or_error.dart';

/// Simula uma verificação externa de conectividade (faz as vezes de um
/// plugin/API real).
///
/// Implementa [Datasource]: retorna o `bool` cru em caso de sucesso ou faz
/// `throw` no [AppError] carregado pelos parâmetros em caso de falha —
/// exatamente o que o `resultDatasource` do usecase espera.
final class FakeConnectivityDatasource implements Datasource<bool> {
  final bool _online;
  final bool _shouldThrow;

  // Private named parameters (Dart 3.12): o chamador usa `online`/`shouldThrow`,
  // enquanto os campos permanecem privados.
  const FakeConnectivityDatasource({
    this._online = true,
    this._shouldThrow = false,
  });

  @override
  Future<bool> call(ParametersReturnResult parameters) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    if (_shouldThrow) {
      throw parameters.error.copyWith(message: "simulated network failure");
    }
    return _online;
  }
}
