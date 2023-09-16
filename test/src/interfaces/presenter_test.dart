import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:return_success_or_error/return_success_or_error.dart';

class ParametersSalvarHeader implements ParametersReturnResult {
  final String nome;

  ParametersSalvarHeader({
    required this.nome,
  });

  @override
  AppError get error => ErrorGeneric(message: "teste parrametros");
}

final class TesteUsecaseDirect extends UsecaseBase<String> {
  final bool testeDependencia;

  TesteUsecaseDirect({required this.testeDependencia});

  @override
  Future<ReturnSuccessOrError<String>> call(
    ParametersReturnResult parameters,
  ) async {
    if (testeDependencia) {
      return SuccessReturn<String>(
        success: "teste",
      );
    } else {
      return ErrorReturn(
        error: parameters.error,
      );
    }
  }
}

final class TestePresenterDirect implements Presenter<String> {
  @override
  Future<ReturnSuccessOrError<String>> call(NoParams parameters) async {
    final instance = TesteUsecaseDirect(testeDependencia: true);
    final data = instance(parameters);
    return data;
  }
}

final class ReturnResultDatasourceMock extends Mock
    implements Datasource<bool> {}

final datasourceMock = ReturnResultDatasourceMock();

final class TesteUsecaseCallData extends UsecaseBaseCallData<String, bool> {
  TesteUsecaseCallData({required super.datasource});

  @override
  Future<ReturnSuccessOrError<String>> call(
      ParametersSalvarHeader parameters) async {
    final teste = await resultDatasource(
      parameters: parameters,
      datasource: datasource,
    );
    print("Teste retorno Datasource - $teste");
    switch (teste) {
      case SuccessReturn<bool>():
        if (teste.result) {
          return SuccessReturn<String>(success: "Regra de negocio true");
        } else {
          return SuccessReturn<String>(success: "Regra de negocio false");
        }

      case ErrorReturn<bool>():
        return ErrorReturn<String>(error: parameters.error);
    }
  }
}

final class TestePresenterCallData implements Presenter<String> {
  @override
  Future<ReturnSuccessOrError<String>> call(
    ParametersSalvarHeader parameters,
  ) {
    final instance = TesteUsecaseCallData(
      datasource: datasourceMock,
    );
    final data = instance(
      parameters,
    );
    return data;
  }
}

void main() {
  final parameters = ParametersSalvarHeader(nome: 'Teste UsecaseBase');
  late TestePresenterDirect returnResultPresenterBase;
  late TestePresenterCallData returnResultPresenterCallData;

  setUp(() {
    returnResultPresenterBase = TestePresenterDirect();
    returnResultPresenterCallData = TestePresenterCallData();
  });

  test('Deve retornar um success com "teste"', () async {
    final data = await returnResultPresenterBase(
      NoParams(),
    );
    switch (data) {
      case SuccessReturn<String>():
        print(data.result);
        expect(data.result, equals("teste"));
      case ErrorReturn<String>():
        print(data.result);
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test('Deve retornar um success com "Regra de negocio OK" data "true"',
      () async {
    when(() => datasourceMock(parameters)).thenAnswer(
      (_) => Future.value(true),
    );
    final data = await returnResultPresenterCallData(
      parameters,
    );
    switch (data) {
      case SuccessReturn<String>():
        print(data.result);
        expect(data.result, equals("Regra de negocio true"));
      case ErrorReturn<String>():
        print(data.result);
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test('Deve retornar um success com "Regra de negocio OK" data "false"',
      () async {
    when(() => datasourceMock(parameters)).thenAnswer(
      (_) => Future.value(false),
    );
    final data = await returnResultPresenterCallData(
      parameters,
    );
    switch (data) {
      case SuccessReturn<String>():
        print(data.result);
        expect(data.result, equals("Regra de negocio false"));
      case ErrorReturn<String>():
        print(data.result);
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test(
      'Deve retornar um AppError com ErrorGeneric - Error General Feature. Cod. 03-1 --- Catch: Exception',
      () async {
    when(() => datasourceMock(parameters)).thenThrow(
      Exception(),
    );
    final data = await returnResultPresenterCallData(
      parameters,
    );
    switch (data) {
      case SuccessReturn<String>():
        print(data.result);
        expect(data.result, equals("Regra de negocio OK"));
      case ErrorReturn<String>():
        print(data.result);
        expect(data.result, isA<ErrorGeneric>());
    }
  });
}
