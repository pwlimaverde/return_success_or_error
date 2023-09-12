import 'dart:isolate';

import 'package:return_success_or_error/return_success_or_error.dart';

class Calc {
  Future<int> isolateFibonacci(int n) async {
    var isolateListnner = ReceivePort();
    var port = ReceivePort();

    await Isolate.spawn(_isolateLogic, port.sendPort);
    SendPort portNewIsolate = await port.first;

    portNewIsolate.send(
      {'isolate': isolateListnner.sendPort, 'value': n},
    );

    return await isolateListnner.first;
  }

  static _isolateLogic(SendPort message) {
    var isolatePrivatePort = ReceivePort();
    message.send(isolatePrivatePort.sendPort);

    isolatePrivatePort.listen((message) {
      var externalIsolate = message['isolate'];
      int value = message['value'];
      externalIsolate.send(fibonacci(value));
    });
  }

  static int fibonacci(int n) {
    if (n == 0 || n == 1) return n;
    return fibonacci(n - 1) + fibonacci(n - 2);
  }

  Future<int> fibonacciPresenter() async {
    final usecase = FibonacciUsecase();
    final data = await usecase.callIsolate(
      NoParams(
        basic: ParametersBasic(
          isIsolate: true,
          showRuntimeMilliseconds: true,
        ),
      ),
    );
    switch (data) {
      case SuccessReturn<int>():
        print("SuccessReturn");
        print(data.result);
        return data.result;
      case ErrorReturn<int>():
        throw Exception();
    }
  }
}

final class FibonacciUsecase extends UsecaseBase<int> {
  @override
  Future<ReturnSuccessOrError<int>> call(
    NoParams parameters,
  ) async {
    final data = _fibonacci(44);
    print("Teste fibonacci $data");
    return SuccessReturn<int>(success: data);
  }

  int _fibonacci(int n) {
    if (n == 0 || n == 1) return n;
    return _fibonacci(n - 1) + _fibonacci(n - 2);
  }
}
