import 'package:flutter_test/flutter_test.dart';
import 'package:retorno_sucesso_ou_erro_package/src/utilitarios/erros.dart';
import 'package:retorno_sucesso_ou_erro_package/src/utilitarios/retorno_sucesso_ou_erro.dart';

void main() {
  test('Deve retornar um sucesso', () {
    final result = SucessoRetorno(resultado: "teste sucesso");
    print(result.fold(
      sucesso: (value) => value.resultado,
      erro: (value) => value.erro,
    ));
    expect(result, isA<RetornoSucessoOuErro<String>>());
  });

  test('Deve retornar um sucesso com o resultado da String', () {
    final result = SucessoRetorno(resultado: "teste sucesso");
    print(result.fold(
      sucesso: (value) => value.resultado,
      erro: (value) => value.erro,
    ));

    expect(
        result.fold(
          sucesso: (value) => value.resultado,
          erro: (value) => value.erro,
        ),
        "teste sucesso");
  });

  test('Deve retornar um error', () {
    final result = ErroRetorno(
      erro: ErroInesperado(
        mensagem: "teste erro",
      ),
    );
    print(result.fold(
      sucesso: (value) => value.resultado,
      erro: (value) => value.erro,
    ));
    expect(result, isA<ErroRetorno>());
  });
}
