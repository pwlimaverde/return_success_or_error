import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:retorno_sucesso_ou_erro_package/retorno_sucesso_ou_erro_package.dart';
import 'package:retorno_sucesso_ou_erro_package/src/core/repositorio.dart';

class ChecarConeccaoUsecase extends UseCase<bool, NoParams> {
  final Repositorio<bool, NoParams> repositorio;

  ChecarConeccaoUsecase({required this.repositorio});

  @override
  Future<RetornoSucessoOuErro<bool>> call(
      {required NoParams parametros}) async {
    final resultado = await retornoRepositorio(
      repositorio: repositorio,
      erro: ErroInesperado(mensagem: "teste erro direto usecase"),
      parametros: NoParams(mensagemErro: 'teste Usecase'),
    );
    return resultado;
  }
}

class ChecarConeccaoRepositorio extends Repositorio<bool, NoParams> {
  final Datasource<bool, NoParams> datasource;

  ChecarConeccaoRepositorio({required this.datasource});

  @override
  Future<RetornoSucessoOuErro<bool>> call({required NoParams parametros}) {
    final resultado = retornoDatasource(
      datasource: datasource,
      erro: ErroInesperado(mensagem: "teste erro direto repositorio"),
      parametros: NoParams(mensagemErro: 'teste Usecase'),
    );
    return resultado;
  }
}

class DatasourceMock extends Mock implements Datasource<bool, NoParams> {}

void main() {
  late Repositorio<bool, NoParams> repositorio;
  late Datasource<bool, NoParams> datasource;
  late UseCase<bool, NoParams> checarConeccaoUseCase;

  setUp(() {
    datasource = DatasourceMock();
    repositorio = ChecarConeccaoRepositorio(datasource: datasource);
    checarConeccaoUseCase = ChecarConeccaoUsecase(repositorio: repositorio);
  });

  test('Deve retornar um sucesso com true', () async {
    when(datasource).calls(#call).thenAnswer((_) => Future.value(true));
    final result = await checarConeccaoUseCase(
        parametros: NoParams(mensagemErro: 'teste Usecase'));
    print("teste result - ${result.fold(
      sucesso: (value) => value.resultado,
      erro: (value) => value.erro,
    )}");
    expect(result, isA<SucessoRetorno<bool>>());
  });

  test('Deve retornar um sucesso com false', () async {
    checarConeccaoUseCase = ChecarConeccaoUsecase(repositorio: repositorio);
    when(datasource).calls(#call).thenAnswer((_) => Future.value(false));
    final result = await checarConeccaoUseCase(
        parametros: NoParams(mensagemErro: 'teste Usecase'));
    print("teste result - ${result.fold(
      sucesso: (value) => value.resultado,
      erro: (value) => value.erro,
    )}");
    expect(result, isA<SucessoRetorno<bool>>());
  });

  test(
      'Deve retornar um Erro com ErroInesperado com teste erro direto repositorio',
      () async {
    checarConeccaoUseCase = ChecarConeccaoUsecase(repositorio: repositorio);
    when(datasource).calls(#call).thenThrow(Exception());
    final result = await checarConeccaoUseCase(
        parametros: NoParams(mensagemErro: 'teste Usecase'));
    print("teste result - ${result.fold(
      sucesso: (value) => value.resultado,
      erro: (value) => value.erro,
    )}");
    expect(result, isA<ErroRetorno<bool>>());
  });
}
