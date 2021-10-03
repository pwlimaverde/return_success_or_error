import 'package:connectivity/connectivity.dart';
import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:return_success_or_error/return_success_or_error.dart';

class ChecarConeccao extends Mock implements Connectivity {}

void main() {
  late Connectivity data;
  late ChecarConeccaoUsecase usecase;

  setUp(() {
    data = ChecarConeccao();
    usecase = ChecarConeccaoUsecase(connectivity: data);
  });

  test('Deve retornar um sucesso com true Coneção wifi', () async {
    when(data)
        .calls(#checkConnectivity)
        .thenAnswer((_) => Future.value(ConnectivityResult.wifi));
    final result = await usecase(
      parameters: NoParams(
        error: ErrorReturnResult(
          message: "Erro de conexão",
        ),
        nameFeature: "Checar Conecção",
        showRuntimeMilliseconds: true,
      ),
    );
    print("teste result - ${result.fold(
      success: (value) => value.result,
      error: (value) => value.error,
    )}");
    expect(result, isA<SuccessReturn<bool>>());
  });

  test('Deve retornar um sucesso com true Coneção mobile', () async {
    when(data)
        .calls(#checkConnectivity)
        .thenAnswer((_) => Future.value(ConnectivityResult.mobile));
    final result = await usecase(
      parameters: NoParams(
        error: ErrorReturnResult(
          message: "Erro de conexão",
        ),
        nameFeature: "Checar Conecção",
        showRuntimeMilliseconds: true,
      ),
    );
    print("teste result - ${result.fold(
      success: (value) => value.result,
      error: (value) => value.error,
    )}");
    expect(result, isA<SuccessReturn<bool>>());
  });

  test(
      'Deve retornar um ErroRetorno com Você está offline Cod.02-1 Coneção none',
      () async {
    when(data)
        .calls(#checkConnectivity)
        .thenAnswer((_) => Future.value(ConnectivityResult.none));
    final result = await usecase(
      parameters: NoParams(
        error: ErrorReturnResult(
          message: "Erro de conexão",
        ),
        nameFeature: "Checar Conecção",
        showRuntimeMilliseconds: true,
      ),
    );
    print("teste result - ${result.fold(
      success: (value) => value.result,
      error: (value) => value.error,
    )}");
    expect(result, isA<ErrorReturn<bool>>());
  });

  test(
      'Deve retornar um ErroRetorno com Você está offline Cod.02-1 Coneção none',
      () async {
    when(data).calls(#checkConnectivity).thenAnswer((_) => Future.value(null));
    final result = await usecase(
      parameters: NoParams(
        error: ErrorReturnResult(
          message: "Erro de conexão",
        ),
        nameFeature: "Checar Conecção",
        showRuntimeMilliseconds: true,
      ),
    );
    print("teste result - ${result.fold(
      success: (value) => value.result,
      error: (value) => value.error,
    )}");
    expect(result, isA<ErrorReturn<bool>>());
  });

  test('Deve retornar um ErroRetorno com Você está offline Cod.02-1 Exeption',
      () async {
    when(data).calls(#checkConnectivity).thenThrow(Exception());
    final result = await usecase(
      parameters: NoParams(
        error: ErrorReturnResult(
          message: "Erro de conexão",
        ),
        nameFeature: "Checar Conecção",
        showRuntimeMilliseconds: true,
      ),
    );
    print("teste result - ${result.fold(
      success: (value) => value.result,
      error: (value) => value.error,
    )}");
    expect(result, isA<ErrorReturn<bool>>());
  });
}
