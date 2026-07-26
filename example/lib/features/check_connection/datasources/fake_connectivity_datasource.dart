import 'dart:async';

import 'package:return_success_or_error/return_success_or_error.dart';

/// Simula uma verificação externa de conectividade (faz as vezes de um
/// plugin/API real).
///
/// É a camada **burra**: devolve o `bool` cru ou **deixa a exceção técnica
/// subir**. Repare que não há `try/catch` nem qualquer menção a erro de
/// domínio — traduzir é papel do repositório.
final class FakeConnectivityDatasource implements Datasource<bool, NoParams> {
  final bool _online;
  final bool _shouldThrow;

  // Private named parameters (Dart 3.12): o chamador usa `online`/`shouldThrow`,
  // enquanto os campos permanecem privados.
  const FakeConnectivityDatasource({
    this._online = true,
    this._shouldThrow = false,
  });

  @override
  Future<bool> call(NoParams parameters) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    if (_shouldThrow) {
      throw TimeoutException('simulated network failure');
    }
    return _online;
  }
}
