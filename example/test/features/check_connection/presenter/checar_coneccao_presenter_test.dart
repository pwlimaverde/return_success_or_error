import 'package:connectivity/connectivity.dart';
import 'package:example/features/check_connection/presenter/checar_coneccao_presenter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:return_success_or_error/return_success_or_error.dart';

class ChecarConeccao extends Mock implements Connectivity {}

void main() {
  late Connectivity data;

  setUp(() {
    data = ChecarConeccao();
  });

  test('Deve retornar um sucesso com true Coneção wifi', () async {
    when(data)
        .calls(#checkConnectivity)
        .thenAnswer((_) => Future.value(ConnectivityResult.wifi));
    final result = await ChecarConeccaoPresenter(
      connectivity: data,
      showRuntimeMilliseconds: true,
    ).consultaConectividade();
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
    final result = await ChecarConeccaoPresenter(
      connectivity: data,
      showRuntimeMilliseconds: true,
    ).consultaConectividade();
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
    final result = await ChecarConeccaoPresenter(
      connectivity: data,
      showRuntimeMilliseconds: true,
    ).consultaConectividade();
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
    final result = await ChecarConeccaoPresenter(
      connectivity: data,
      showRuntimeMilliseconds: true,
    ).consultaConectividade();
    print("teste result - ${result.fold(
      success: (value) => value.result,
      error: (value) => value.error,
    )}");
    expect(result, isA<ErrorReturn<bool>>());
  });

  test('Deve retornar um ErroRetorno com Você está offline Cod.02-1 Exeption',
      () async {
    when(data).calls(#checkConnectivity).thenThrow(Exception());
    final result = await ChecarConeccaoPresenter(
      connectivity: data,
      showRuntimeMilliseconds: true,
    ).consultaConectividade();
    print("teste result - ${result.fold(
      success: (value) => value.result,
      error: (value) => value.error,
    )}");
    expect(result, isA<ErrorReturn<bool>>());
  });
}
