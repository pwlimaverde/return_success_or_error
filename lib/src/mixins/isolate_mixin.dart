import 'dart:isolate';
import '../../return_success_or_error.dart';

///mixim responsible for loading the datasource, choosing to run the function in an isolate or not.
mixin IsolateMixin<TypeUsecase> {
  Future<ReturnSuccessOrError<TypeUsecase>> returnIsolate({
    required covariant ParametersReturnResult parameters,
    required Future<ReturnSuccessOrError<TypeUsecase>> callUsecase,
  }) async {
    final String _messageError = parameters.basic.error.message;
    try {
      final Future<ReturnSuccessOrError<TypeUsecase>> _result =
          parameters.basic.isIsolate
              ? _funcaoIsolate(funcao: await callUsecase)
              : callUsecase;
      return _result;
    } catch (e) {
      return ErrorReturn(
        error: parameters.basic.error
          ..message = "$_messageError. \n Cod. 03-1 --- Catch: $e",
      );
    }
  }

  Future<ReturnSuccessOrError<TypeUsecase>> _funcaoIsolate({
    required ReturnSuccessOrError<TypeUsecase> funcao,
  }) async {
    ReceivePort _receiveIsolatePort = ReceivePort();
    await Isolate.spawn(_envioRetornoFuncao, _receiveIsolatePort.sendPort);
    SendPort _sendToIsolatePort = await _receiveIsolatePort.first;
    ReturnSuccessOrError<TypeUsecase> _result =
        await _recebimentoRetornoFuncao(_sendToIsolatePort, funcao);
    return _result;
  }

  Future<void> _envioRetornoFuncao(SendPort sendPort) async {
    ReceivePort _port = ReceivePort();
    sendPort.send(_port.sendPort);
    await for (var msg in _port) {
      ReturnSuccessOrError<TypeUsecase> _data = msg[0];
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
