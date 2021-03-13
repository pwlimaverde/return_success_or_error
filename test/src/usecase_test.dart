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
      parametros: NoParams(mensagemErro: 'teste Usecase'),
      erro: ErroInesperado(mensagem: "teste erro direto usecase"),
    );
    return resultado;
  }
}

class RepositorioMock extends Mock implements Repositorio<bool, NoParams> {}

void main() {
  late Repositorio<bool, NoParams> repositorio;
  late UseCase<bool, NoParams> checarConeccaoUseCase;

  setUp(() {
    repositorio = RepositorioMock();
    checarConeccaoUseCase = ChecarConeccaoUsecase(repositorio: repositorio);
  });

  test('Deve retornar um sucesso com true', () async {
    when(repositorio)
        .calls(#call)
        .thenAnswer((_) => Future.value(SucessoRetorno<bool>(resultado: true)));
    final result = await checarConeccaoUseCase(
        parametros: NoParams(mensagemErro: 'teste Usecase'));
    print("teste result - ${result.fold(
      sucesso: (value) => value.resultado,
      erro: (value) => value.erro,
    )}");
    expect(result, isA<SucessoRetorno<bool>>());
  });

  test('Deve retornar um sucesso com false', () async {
    when(repositorio).calls(#call).thenAnswer(
        (_) => Future.value(SucessoRetorno<bool>(resultado: false)));
    final result = await checarConeccaoUseCase(
        parametros: NoParams(mensagemErro: 'teste Usecase'));
    print("teste result - ${result.fold(
      sucesso: (value) => value.resultado,
      erro: (value) => value.erro,
    )}");
    expect(result, isA<SucessoRetorno<bool>>());
  });

  test('Deve retornar um Erro com ErroInesperado com teste erro', () async {
    when(repositorio).calls(#call).thenAnswer((_) => Future.value(
        ErroRetorno<bool>(erro: ErroInesperado(mensagem: "teste erro"))));
    final result = await checarConeccaoUseCase(
        parametros: NoParams(mensagemErro: 'teste Usecase'));
    print("teste result - ${result.fold(
      sucesso: (value) => value.resultado,
      erro: (value) => value.erro,
    )}");
    expect(result, isA<ErroRetorno<bool>>());
  });

  test('Deve retornar um Erro com ErroInesperado com erro direto usecase',
      () async {
    when(repositorio).calls(#call).thenThrow(Exception());
    final result = await checarConeccaoUseCase(
        parametros: NoParams(mensagemErro: 'teste Usecase'));
    print("teste result - ${result.fold(
      sucesso: (value) => value.resultado,
      erro: (value) => value.erro,
    )}");
    expect(result, isA<ErroRetorno<bool>>());
  });
}
