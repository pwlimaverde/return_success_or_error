import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:return_success_or_error/src/interfaces/datasource.dart';
import 'package:return_success_or_error/src/core/errors.dart';
import 'package:return_success_or_error/src/core/parameters.dart';
import 'package:return_success_or_error/src/core/return_success_or_error_class.dart';
import 'package:return_success_or_error/src/features/return_result/presenter/return_result_usecase_implement.dart';

class FairebaseSalvarHeaderDatasourceMock extends Mock
    implements Datasource<bool> {}

void main() {
  late Datasource<bool> datasource;

  setUp(() {
    datasource = FairebaseSalvarHeaderDatasourceMock();
  });

  test('Deve retornar um success com true', () async {
    when(datasource).calls(#call).thenAnswer((_) => Future.value(true));
    final result = await ReturnResultUsecaseImplement<bool>(
      datasource: datasource,
      showRuntimeMilliseconds: true,
      nameFeature: 'SalvarHeader',
    )(
      parameters: ParametersSalvarHeader(
        corHeader: {
          "r": 60,
          "g": 60,
          "b": 60,
        },
        doc: 'testedoc',
        nome: 'novidades',
        prioridade: 1,
        user: 'paulo',
      ),
    );
    print("teste result - ${await result.fold(
      success: (value) => value.result,
      error: (value) => value.error,
    )}");
    expect(result, isA<SuccessReturn<bool>>());
    expect(
        result.fold(
          success: (value) => value.result,
          error: (value) => value.error,
        ),
        true);
  });

  test('Deve retornar success com false', () async {
    when(datasource).calls(#call).thenAnswer((_) => Future.value(false));
    final result = await ReturnResultUsecaseImplement<bool>(
      datasource: datasource,
      showRuntimeMilliseconds: true,
      nameFeature: 'SalvarHeader',
    )(
      parameters: ParametersSalvarHeader(
        corHeader: {
          "r": 60,
          "g": 60,
          "b": 60,
        },
        doc: 'testedoc',
        nome: 'novidades',
        prioridade: 1,
        user: 'paulo',
      ),
    );
    print("teste result - ${await result.fold(
      success: (value) => value.result,
      error: (value) => value.error,
    )}");
    expect(result, isA<SuccessReturn<bool>>());
    expect(
        result.fold(
          success: (value) => value.result,
          error: (value) => value.error,
        ),
        false);
  });

  test(
      'Deve retornar ErrorReturnResult com Erro ao salvar os dados do header Cod.02-1',
      () async {
    when(datasource).calls(#call).thenThrow(Exception());
    final result = await ReturnResultUsecaseImplement<bool>(
      datasource: datasource,
      showRuntimeMilliseconds: true,
      nameFeature: 'SalvarHeader',
    )(
      parameters: ParametersSalvarHeader(
        corHeader: {
          "r": 60,
          "g": 60,
          "b": 60,
        },
        doc: 'testedoc',
        nome: 'novidades',
        prioridade: 1,
        user: 'paulo',
      ),
    );
    print("teste result - ${await result.fold(
      success: (value) => value.result,
      error: (value) => value.error,
    )}");
    expect(result, isA<ErrorReturn<bool>>());
  });
}

class ParametersSalvarHeader implements ParametersReturnResult {
  final String doc;
  final String nome;
  final int prioridade;
  final Map corHeader;
  final String user;

  ParametersSalvarHeader({
    required this.doc,
    required this.nome,
    required this.prioridade,
    required this.corHeader,
    required this.user,
  });

  @override
  AppError get error =>
      ErrorReturnResult(message: "Erro ao salvar os dados do Header");
}
