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
    final String messageError = parameters.basic.error.message;
    try {
      final TypeDatasource _result = parameters.basic.isIsolate
          ? await funcaoIsolate(
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
          ..message = "$messageError. \n Cod. 03-1 --- Catch: $e",
      );
    }
  }

  Future<dynamic> funcaoIsolate({required TypeDatasource funcao}) async {
    ReceivePort receiveIsolatePort = ReceivePort();
    await Isolate.spawn(_envioRetornoFuncao, receiveIsolatePort.sendPort);
    SendPort sendToIsolatePort = await receiveIsolatePort.first;
    TypeDatasource result =
        await _recebimentoRetornoFuncao(sendToIsolatePort, funcao);
    return result;
  }

  Future<void> _envioRetornoFuncao(SendPort sendPort) async {
    ReceivePort port = ReceivePort();
    sendPort.send(port.sendPort);
    await for (var msg in port) {
      TypeDatasource data = msg[0];
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
