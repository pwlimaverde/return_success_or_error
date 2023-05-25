import 'dart:isolate';

import '../core/parameters.dart';
import '../core/return_success_or_error.dart';
import '../interfaces/datasource.dart';

mixin ReturnDatasourcetMixin<R> {
  Future<ReturnSuccessOrError<R>> returnDatasource({
    required ParametersReturnResult parameters,
    required Datasource<R> datasource,
  }) async {
    final String messageError = parameters.basic.error.message;
    try {
      final R result = parameters.basic.isIsolate
          ? await funcaoIsolate(
              funcao: await datasource.call(
              parameters: parameters,
            ))
          : await datasource.call(
              parameters: parameters,
            );
      return SuccessReturn<R>(
        success: result,
      );
    } catch (e) {
      return ErrorReturn<R>(
        error: parameters.basic.error
          ..message = "$messageError. \n Cod. 03-1 --- Catch: $e",
      );
    }
  }

  Future<dynamic> funcaoIsolate({required R funcao}) async {
    ReceivePort receiveIsolatePort = ReceivePort();
    await Isolate.spawn(_envioRetornoFuncao, receiveIsolatePort.sendPort);
    SendPort sendToIsolatePort = await receiveIsolatePort.first;
    R result = await _recebimentoRetornoFuncao(sendToIsolatePort, funcao);
    return result;
  }

  Future<void> _envioRetornoFuncao(SendPort sendPort) async {
    ReceivePort port = ReceivePort();
    sendPort.send(port.sendPort);
    await for (var msg in port) {
      R data = msg[0];
      SendPort replyTo = msg[1];
      replyTo.send(data);
    }
  }

  Future<dynamic> _recebimentoRetornoFuncao(SendPort port, resultado) {
    ReceivePort response = ReceivePort();
    port.send([resultado, response.sendPort]);
    return response.first;
  }
}
