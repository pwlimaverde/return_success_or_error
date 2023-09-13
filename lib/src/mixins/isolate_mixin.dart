import 'dart:isolate';
import '../../return_success_or_error.dart';

///mixim responsible for loading the call usecase, choosing to run the function in an isolate or not.
mixin IsolateMixin<TypeUsecase> {
  Future<ReturnSuccessOrError<TypeUsecase>> returnIsolate({
    required covariant ParametersReturnResult parameters,
    required Function call,
  }) async {
    final String _messageError = parameters.error.message;

    try {
      final _result = await _callIsolate(
        call: call,
        parameters: parameters,
      );

      if (_result is ReturnSuccessOrError<TypeUsecase>) {
        return _result;
      } else {
        return ErrorReturn(
          error: parameters.error..message = "$_messageError. \n Cod. 02-1",
        );
      }
    } catch (e) {
      return ErrorReturn(
        error: parameters.error
          ..message = "$_messageError. \n Cod. 03-1 --- Catch: $e",
      );
    }
  }

  Future<dynamic> _callIsolate({
    required Function call,
    required covariant ParametersReturnResult parameters,
  }) async {
    try {
      var isolateListnner = ReceivePort();
      var port = ReceivePort();

      await Isolate.spawn(_isolateLogic, port.sendPort);
      SendPort portNewIsolate = await port.first;

      portNewIsolate.send(
        {
          'isolate': isolateListnner.sendPort,
          'call': call,
          'parameters': parameters,
        },
      );

      return await isolateListnner.first;
    } catch (e) {
      throw Exception(e);
    }
  }

  static _isolateLogic(SendPort message) {
    try {
      var isolatePrivatePort = ReceivePort();
      message.send(isolatePrivatePort.sendPort);

      isolatePrivatePort.listen((message) async {
        var externalIsolate = message['isolate'];
        var parameters = message['parameters'];
        Function call = message['call'];

        externalIsolate.send(await call(parameters));
      });
    } catch (e) {
      throw Exception(e);
    }
  }
}
