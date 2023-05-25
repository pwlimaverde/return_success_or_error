import 'package:connectivity_plus/connectivity_plus.dart';
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
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet;
  }

  @override
  Future<bool> call({required ParametersReturnResult parameters}) async {
    try {
      final result = await isOnline;
      if (!result) {
        throw parameters.basic.error..message = "Você está offline";
      }
      return result;
    } catch (e) {
      throw parameters.basic.error..message = "$e";
    }
  }
}

void main() {
  late Connectivity connectivityMock;
  late Datasource<bool> connectivityDatasource;
  late ChecarConeccaoUsecase usecase;
  final parameters = NoParams(
    error: ErrorReturnResult(
      message: "Erro de conexão",
    ),
    nameFeature: "Checar Conecção",
    showRuntimeMilliseconds: true,
    isIsolate: false,
  );

  setUp(() {
    connectivityMock = ConnectivityMock();
    connectivityDatasource =
        ConnectivityDatasource(connectivity: connectivityMock);
    usecase = ChecarConeccaoUsecase(datasource: connectivityDatasource);
  });

  test('Deve retornar um sucesso com true Coneção wifi', () async {
    when(() => connectivityMock.checkConnectivity())
        .thenAnswer((_) => Future.value(ConnectivityResult.wifi));
    final result = await usecase(
      parameters: parameters,
    );
    print("teste status - ${result.status}");
    print("teste result - ${result.result}");
    expect(result, isA<SuccessReturn<bool>>());
    expect(result.result, equals(true));
  });

  test('Deve retornar um sucesso com true Coneção mobile', () async {
    when(() => connectivityMock.checkConnectivity())
        .thenAnswer((_) => Future.value(ConnectivityResult.mobile));
    final result = await usecase(
      parameters: parameters,
    );
    print("teste status - ${result.status}");
    print("teste result - ${result.result}");
    expect(result, isA<SuccessReturn<bool>>());
    expect(result.result, equals(true));
  });

  test(
      'Deve retornar um ErroRetorno com Você está offline Cod.03-1 Coneção none',
      () async {
    when(() => connectivityMock.checkConnectivity())
        .thenAnswer((_) => Future.value(ConnectivityResult.none));
    final result = await usecase(
      parameters: parameters,
    );
    print("teste status - ${result.status}");
    print("teste result - ${result.result}");
    expect(result, isA<ErrorReturn<bool>>());
  });

  test('Deve retornar um ErroRetorno com Você está offline Cod.03-1 Exeption',
      () async {
    when(() => connectivityMock.checkConnectivity()).thenThrow(Exception());
    final result = await usecase(
      parameters: parameters,
    );
    print("teste status - ${result.status}");
    print("teste result - ${result.result}");
    expect(result, isA<ErrorReturn<bool>>());
  });
}
