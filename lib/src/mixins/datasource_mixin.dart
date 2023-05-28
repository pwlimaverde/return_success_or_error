import 'dart:isolate';
import '../core/parameters.dart';
import '../interfaces/datasource.dart';
import '../interfaces/errors.dart';

///mixim responsible for loading the datasource, choosing to run the function in an isolate or not.
mixin DatasourceMixin<TypeDatasource> {
  Future<({TypeDatasource? result, AppError? error})> returnDatasource({
    required ParametersReturnResult parameters,
    required Datasource<TypeDatasource> datasource,
  }) async {
    final String _messageError = parameters.basic.error.message;
    try {
      final TypeDatasource _result = parameters.basic.isIsolate
          ? await _funcaoIsolate(
              funcao: await datasource.call(
              parameters: parameters,
            ))
          : await datasource.call(
              parameters: parameters,
            );
      return (result: _result, error: null);
    } catch (e) {
      return (
        result: null,
        error: parameters.basic.error
          ..message = "$_messageError. \n Cod. 03-1 --- Catch: $e",
      );
    }
  }

  Future<dynamic> _funcaoIsolate({required TypeDatasource funcao}) async {
    ReceivePort _receiveIsolatePort = ReceivePort();
    await Isolate.spawn(_envioRetornoFuncao, _receiveIsolatePort.sendPort);
    SendPort _sendToIsolatePort = await _receiveIsolatePort.first;
    TypeDatasource _result =
        await _recebimentoRetornoFuncao(_sendToIsolatePort, funcao);
    return _result;
  }

  Future<void> _envioRetornoFuncao(SendPort sendPort) async {
    ReceivePort _port = ReceivePort();
    sendPort.send(_port.sendPort);
    await for (var msg in _port) {
      TypeDatasource _data = msg[0];
      SendPort _replyTo = msg[1];
      _replyTo.send(_data);
    }
  }

  Future<dynamic> _recebimentoRetornoFuncao(SendPort port, resultado) {
    ReceivePort _response = ReceivePort();
    port.send([resultado, _response.sendPort]);
    return _response.first;
  }
}
