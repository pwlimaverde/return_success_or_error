import 'dart:isolate';
import '../../return_success_or_error.dart';

///mixim responsible for loading the call usecase, choosing to run the function in an isolate or not.
mixin IsolateMixin<TypeUsecase> {
  Future<ReturnSuccessOrError<TypeUsecase>> returnIsolate({
    required covariant ParametersReturnResult parameters,
    required Function callUsecase,
  }) async {
    final String _messageError = parameters.basic.error.message;
    try {
      final _result = parameters.basic.isIsolate
          ? _funcaoIsolate(
              callUsecase: callUsecase,
              parameters: parameters,
            )
          : callUsecase;

      if (_result is Future<ReturnSuccessOrError<TypeUsecase>>) {
        return _result;
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

  Future<ReturnSuccessOrError<TypeUsecase>> _funcaoIsolate({
    required Function callUsecase,
    required covariant ParametersReturnResult parameters,
  }) async {
    var isolateListnner = ReceivePort();
    var port = ReceivePort();

    await Isolate.spawn(_isolateLogic, port.sendPort);
    SendPort portNewIsolate = await port.first;

    portNewIsolate.send(
      {
        'isolate': isolateListnner.sendPort,
        'callUsecase': callUsecase,
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
      Function callUsecase = message['callUsecase'];
      externalIsolate.send(await callUsecase(parameters));
    });
  }
}
