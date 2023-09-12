import 'dart:isolate';
import '../core/parameters.dart';
import '../core/return_success_or_error.dart';

///mixim responsible for loading the datasource, choosing to run the function in an isolate or not.
mixin DatasourceMixin<TypeDatasource> {
  Future<ReturnSuccessOrError<TypeDatasource>> returnDatasource({
    required covariant ParametersReturnResult parameters,
    required Function datasource,
  }) async {
    final String _messageError = parameters.basic.error.message;
    try {
      final _result = parameters.basic.isIsolate
          ? await _funcaoIsolate(
              datasource: datasource,
              parameters: parameters,
            )
          : datasource;
      if (_result is TypeDatasource) {
        return SuccessReturn(success: _result);
      } else {
        return ErrorReturn(
          error: parameters.basic.error
            ..message = "$_messageError. \n Cod. 02-1",
        );
      }
    } catch (e) {
      return ErrorReturn(
        error: parameters.basic.error
          ..message = "$_messageError. \n Cod. 03-1 --- Catch: $e",
      );
    }
  }

  Future<TypeDatasource> _funcaoIsolate({
    required Function datasource,
    required covariant ParametersReturnResult parameters,
  }) async {
    var isolateListnner = ReceivePort();
    var port = ReceivePort();

    await Isolate.spawn(_isolateLogic, port.sendPort);
    SendPort portNewIsolate = await port.first;

    portNewIsolate.send(
      {
        'isolate': isolateListnner.sendPort,
        'datasource': datasource,
        'parameters': parameters,
      },
    );

    return await isolateListnner.first;
  }

  _isolateLogic(SendPort message) {
    var isolatePrivatePort = ReceivePort();
    message.send(isolatePrivatePort.sendPort);

    isolatePrivatePort.listen((message) async {
      var externalIsolate = message['isolate'];
      var parameters = message['parameters'];
      Function datasource = message['datasource'];
      externalIsolate.send(await datasource(parameters));
    });

    //   final String _messageError = parameters.basic.error.message;
    //   try {
    //     final TypeDatasource _result = parameters.basic.isIsolate
    //         ? await _funcaoIsolate(
    //             funcao: await datasource.call(
    //             parameters,
    //           ))
    //         : await datasource.call(
    //             parameters,
    //           );
    //     return SuccessReturn(success: _result);
    //   } catch (e) {
    //     return ErrorReturn(
    //       error: parameters.basic.error
    //         ..message = "$_messageError. \n Cod. 03-1 --- Catch: $e",
    //     );
    //   }
    // }

    // Future<dynamic> _funcaoIsolate({required TypeDatasource funcao}) async {
    //   ReceivePort _receiveIsolatePort = ReceivePort();
    //   await Isolate.spawn(_envioRetornoFuncao, _receiveIsolatePort.sendPort);
    //   SendPort _sendToIsolatePort = await _receiveIsolatePort.first;
    //   TypeDatasource _result =
    //       await _recebimentoRetornoFuncao(_sendToIsolatePort, funcao);
    //   return _result;
    // }

    // Future<void> _envioRetornoFuncao(SendPort sendPort) async {
    //   ReceivePort _port = ReceivePort();
    //   sendPort.send(_port.sendPort);
    //   await for (var msg in _port) {
    //     TypeDatasource _data = msg[0];
    //     SendPort _replyTo = msg[1];
    //     _replyTo.send(_data);
    //   }
    // }

    // Future<dynamic> _recebimentoRetornoFuncao(SendPort port, resultado) {
    //   ReceivePort _response = ReceivePort();
    //   port.send([resultado, _response.sendPort]);
    //   return _response.first;
    // }
  }
}
