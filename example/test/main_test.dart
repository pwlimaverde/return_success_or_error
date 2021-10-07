import 'package:connectivity/connectivity.dart';
import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:return_success_or_error/return_success_or_error.dart';

class ConnectivityMock extends Mock implements Connectivity {}

class ConnectivityDatasource implements Datasource<bool> {
  final Connectivity connectivity;
  ConnectivityDatasource({required this.connectivity});

  Future<bool> get isOnline async {
    var result = await connectivity.checkConnectivity();
    return result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile;
  }

  @override
  Future<bool> call({required ParametersReturnResult parameters}) async {
    final String messageError = parameters.error.message;
    try {
      final result = await isOnline;
      if (!result) {
        throw parameters.error..message = "Você está offline";
      }
      return result;
    } catch (e) {
      throw parameters.error
        ..message = "$messageError - Cod. 03-1 --- Catch: $e";
    }
  }
}

void main() {
  late Connectivity connectivityMock;
  late Datasource<bool> connectivityDatasource;
  late ChecarConeccaoUsecase usecase;

  setUp(() {
    connectivityMock = ConnectivityMock();
    connectivityDatasource =
        ConnectivityDatasource(connectivity: connectivityMock);
    usecase = ChecarConeccaoUsecase(datasource: connectivityDatasource);
  });

  test('Deve retornar um sucesso com true Coneção wifi', () async {
    when(connectivityMock)
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
    when(connectivityMock)
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
    when(connectivityMock)
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
    when(connectivityMock)
        .calls(#checkConnectivity)
        .thenAnswer((_) => Future.value(null));
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
    when(connectivityMock).calls(#checkConnectivity).thenThrow(Exception());
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
